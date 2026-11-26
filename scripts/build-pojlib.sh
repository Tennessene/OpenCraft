#!/usr/bin/env bash
# Build Pojlib (the launcher library in pojlib/) into Pojlib-release.aar and put
# it in the Unity app, replacing the prebuilt copy in wrapper/.
#
# Needs: JDK 11 or 17 (JAVA_HOME), Android SDK (ANDROID_HOME) with
#        platform android-34, build-tools 30.0.3 and NDK 26.1.10909125 (r26b).
set -euo pipefail
cd "$(dirname "$0")/.."

: "${ANDROID_HOME:=${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
export ANDROID_HOME ANDROID_SDK_ROOT="$ANDROID_HOME"

if [ ! -d "$ANDROID_HOME/ndk/26.1.10909125" ]; then
  echo "NDK 26.1.10909125 not found under $ANDROID_HOME/ndk." >&2
  echo "Install it with: sdkmanager 'ndk;26.1.10909125'" >&2
  exit 1
fi

# ':assembleRelease' builds only the Android library. The jre_lwjgl3glfw
# subproject needs a Java 8 toolchain, and its jar is already committed.
(cd pojlib && chmod +x gradlew && ./gradlew --no-daemon :assembleRelease)

AAR=pojlib/build/outputs/aar/Pojlib-release.aar
DEST=wrapper/Assets/Plugins/Android/Pojlib-release.aar
cp "$AAR" "$DEST"
echo "Built $AAR and copied it to $DEST"
