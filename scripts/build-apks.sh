#!/usr/bin/env bash
# Builds an OpenCraft APK for each branch you name (default: main and mc-26.3).
#
#   ./scripts/build-apks.sh                 # build main and mc-26.3
#   ./scripts/build-apks.sh mc-26.3         # build one branch
#   ./scripts/build-apks.sh --install       # also install them on a headset plugged in over USB
#
# For each branch it:
#   1. checks the branch out into build/worktrees/<branch> (kept, so Unity's import cache is reused),
#   2. takes the Pojlib AAR that CI built for that exact commit (no Android NDK needed here),
#   3. if the branch has vivecraft/, builds that mod here and puts it inside the AAR, where
#      Pojlib installs it from for "bundled:" links in mods.json,
#   4. builds the APK with Unity into build/apks/OpenCraft-<branch>.apk.
#
# Each branch gets its own app ID, so the APKs install side by side. main is
# io.github.tennessene.opencraft; other branches add a suffix.
#
# Needs: git, gh (signed in), Unity 2022.3.62f3 with Android Build Support and an
# activated licence (sign in to Unity Hub once), and a JDK 17+ for building Vivecraft.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

INSTALL=0
BRANCHES=()
for arg in "$@"; do
  case "$arg" in
    --install) INSTALL=1 ;;
    -h|--help) sed -n 2,20p "$0"; exit 0 ;;
    *) BRANCHES+=("$arg") ;;
  esac
done
[ ${#BRANCHES[@]} -gt 0 ] || BRANCHES=(main mc-26.3)

UNITY_VERSION=2022.3.62f3
find_unity() {
  [ -n "${UNITY:-}" ] && { echo "$UNITY"; return; }
  for base in /Applications/Unity/Hub/Editor "$HOME/Applications/Unity/Hub/Editor" /Applications/Unity "$HOME/Unity/Hub/Editor"; do
    local app="$base/$UNITY_VERSION/Unity.app/Contents/MacOS/Unity"
    [ -x "$app" ] && { echo "$app"; return; }
  done
  local found
  found=$(find /Applications "$HOME/Applications" -maxdepth 6 -path "*$UNITY_VERSION*/Unity.app/Contents/MacOS/Unity" 2>/dev/null | head -1 || true)
  [ -n "$found" ] && echo "$found"
}
UNITY="$(find_unity || true)"
[ -n "$UNITY" ] || { echo "Unity $UNITY_VERSION not found. Install it, or set UNITY=/path/to/Unity." >&2; exit 1; }
export UNITY
EDITOR_DIR="$(cd "$(dirname "$UNITY")/../../.." && pwd)"

find_jdk17() {
  for home in "${JAVA_HOME:-}" $(/usr/libexec/java_home -v 17+ 2>/dev/null || true) "$HOME"/.sdkman/candidates/java/* /opt/homebrew/opt/openjdk*/libexec/openjdk.jdk/Contents/Home; do
    [ -x "$home/bin/java" ] || continue
    local major
    major=$("$home/bin/java" -XshowSettings:properties -version 2>&1 | awk -F'= ' '/java.specification.version/{print $2}')
    [ "${major%%.*}" -ge 17 ] 2>/dev/null && { echo "$home"; return; }
  done
}

REPO="$(git remote get-url origin | sed -E 's#(git@github.com:|https://github.com/)##; s#\.git$##')"
mkdir -p build/apks build/worktrees
git fetch --quiet origin

for BR in "${BRANCHES[@]}"; do
  echo "=== $BR"
  SHA="$(git rev-parse "origin/$BR")"
  WT="build/worktrees/$BR"
  if [ -d "$WT" ]; then
    git -C "$WT" checkout --quiet --force --detach "$SHA"
  else
    git worktree add --quiet --force --detach "$WT" "$SHA"
  fi

  # 2. The Pojlib AAR CI built for this commit. Wait if that run is still going.
  RUN="$(gh run list -R "$REPO" --branch "$BR" --limit 30 \
        --json databaseId,headSha --jq "[.[] | select(.headSha == \"$SHA\")][0].databaseId // empty")"
  [ -n "$RUN" ] || { echo "No CI run for $BR at ${SHA:0:7}. Push the branch and let CI finish, then run this again." >&2; exit 1; }
  gh run watch "$RUN" -R "$REPO" --exit-status > /dev/null || { echo "CI run $RUN for $BR failed." >&2; exit 1; }
  ART="build/artifacts/$BR"
  rm -rf "$ART"; mkdir -p "$ART"
  gh run download "$RUN" -R "$REPO" -n Pojlib-release -D "$ART"
  AAR="$(ls "$ART"/*.aar | head -1)"

  # 3. Build and bundle the branch's own Vivecraft, if it has one.
  if [ -f "$WT/vivecraft/build.gradle" ]; then
    NAME="$(grep -oE '"bundled:[^"]*vivecraft[^"]*"' "$WT/pojlib/mods.json" | head -1 | sed -E 's/"bundled:(.*)"/\1/')"
    [ -n "$NAME" ] || { echo "$BR has vivecraft/ but no bundled: Vivecraft link in pojlib/mods.json." >&2; exit 1; }
    JDK="$(find_jdk17 || true)"
    [ -n "$JDK" ] || { echo "Building Vivecraft needs a JDK 17 or newer." >&2; exit 1; }
    echo "Building Vivecraft for $BR"
    (cd "$WT/vivecraft" && JAVA_HOME="$JDK" ./gradlew --quiet --no-daemon -Pplatforms=fabric :fabric:build -x test)
    JAR="$(ls "$WT"/vivecraft/build/libs/*-fabric.jar | head -1)"
    STAGE="$ART/stage"; mkdir -p "$STAGE/assets/bundled"
    cp "$JAR" "$STAGE/assets/bundled/$NAME"
    (cd "$STAGE" && zip -q "$ROOT/$AAR" "assets/bundled/$NAME")
    echo "Bundled $(basename "$JAR") as assets/bundled/$NAME"
  fi
  cp "$AAR" "$WT/wrapper/Assets/Plugins/Android/Pojlib-release.aar"

  # 4. Build the APK.
  SUFFIX="$(echo "$BR" | tr -cd 'a-zA-Z0-9' | tr 'A-Z' 'a-z')"
  if [ "$BR" = main ]; then APP_ID=io.github.tennessene.opencraft; APP_NAME=OpenCraft
  else APP_ID="io.github.tennessene.opencraft.$SUFFIX"; APP_NAME="OpenCraft ($BR)"; fi
  APK="$ROOT/build/apks/OpenCraft-$BR.apk"
  OPENCRAFT_APK="$APK" OPENCRAFT_APP_ID="$APP_ID" OPENCRAFT_APP_NAME="$APP_NAME" \
    "$WT/scripts/build-apk.sh" > "build/apks/OpenCraft-$BR.unity.log" 2>&1 \
    || { echo "Unity build for $BR failed. Log: build/apks/OpenCraft-$BR.unity.log" >&2; exit 1; }
  echo "Built $APK ($APP_ID)"

  if [ "$INSTALL" = 1 ]; then
    ADB="$EDITOR_DIR/PlaybackEngines/AndroidPlayer/SDK/platform-tools/adb"
    [ -x "$ADB" ] || ADB="$(command -v adb || true)"
    [ -n "$ADB" ] || { echo "adb not found; install the APK with SideQuest instead." >&2; exit 1; }
    "$ADB" install -r "$APK"
  fi
done

echo
echo "APKs are in build/apks/."
