#!/usr/bin/env bash
# Build the OpenCraft APK from the Unity wrapper in batch mode.
#
# Needs: Unity 2022.3.62f3 (2022 LTS) with "Android Build Support" (incl. OpenJDK,
#        Android SDK & NDK Tools) installed through Unity Hub, and a
#        signed-in Unity account (a free Personal license works).
#
# Optional env:
#   UNITY            path to the Unity binary
#   OPENCRAFT_APK    output path (default: build/OpenCraft.apk)
#   OPENCRAFT_KEYSTORE, OPENCRAFT_KEYSTORE_PASS, OPENCRAFT_KEY_ALIAS,
#   OPENCRAFT_KEY_PASS   sign with your own keystore (otherwise Unity's
#                        debug key is used)
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$PWD"

UNITY_VERSION=2022.3.62f3
if [ -z "${UNITY:-}" ]; then
  for base in /Applications/Unity/Hub/Editor "$HOME/Applications/Unity/Hub/Editor" /Applications/Unity; do
    [ -x "$base/$UNITY_VERSION/Unity.app/Contents/MacOS/Unity" ] && UNITY="$base/$UNITY_VERSION/Unity.app/Contents/MacOS/Unity" && break
  done
fi
: "${UNITY:=/Applications/Unity/Hub/Editor/$UNITY_VERSION/Unity.app/Contents/MacOS/Unity}"
if [ ! -x "$UNITY" ]; then
  echo "Unity $UNITY_VERSION not found at $UNITY. Install it from Unity Hub" >&2
  echo "(Installs > Install Editor > Archive > $UNITY_VERSION, add Android Build Support)," >&2
  echo "or set UNITY=/path/to/Unity." >&2
  exit 1
fi

export OPENCRAFT_APK="${OPENCRAFT_APK:-$ROOT/build/OpenCraft.apk}"
mkdir -p "$(dirname "$OPENCRAFT_APK")"

# Drop the build entry point into the Unity project for this run only.
HOOK_DIR=wrapper/Assets/Editor/OpenCraft
mkdir -p "$HOOK_DIR"
cp tools/unity/OpenCraftBuild.cs "$HOOK_DIR/"
trap 'rm -rf "$HOOK_DIR" "$HOOK_DIR.meta"' EXIT

"$UNITY" -batchmode -nographics \
  -projectPath "$ROOT/wrapper" \
  -buildTarget Android \
  -executeMethod OpenCraftBuild.BuildAndroid \
  -logFile -

echo "APK: $OPENCRAFT_APK"
