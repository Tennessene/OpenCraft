#!/usr/bin/env bash
# Added for OpenCraft (2026-11-26). Builds libSDL3.so for arm64 Android from the
# official SDL sources, with the offscreen video driver that 26.x game versions
# draw through. Subsystems that would need SDL's Android Java glue (joystick,
# haptics, sensors, audio, camera) are left out: the game only starts SDL video.
#
# Usage: build-sdl3.sh <path to Android NDK> [output .so path]
set -euo pipefail

SDL_TAG=release-3.4.20
NDK="${1:?pass the Android NDK path}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${2:-$HERE/src/main/jniLibs/arm64-v8a/libSDL3.so}"
WORK="$HERE/build/sdl3"

if [ ! -d "$WORK/src/.git" ]; then
  rm -rf "$WORK/src"
  git clone --quiet --depth 1 --branch "$SDL_TAG" https://github.com/libsdl-org/SDL.git "$WORK/src"
fi

cmake -S "$WORK/src" -B "$WORK/out" -G "Unix Makefiles" \
  -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-29 -DCMAKE_BUILD_TYPE=Release \
  -DSDL_SHARED=ON -DSDL_STATIC=OFF -DSDL_TEST_LIBRARY=OFF -DSDL_EXAMPLES=OFF -DSDL_ANDROID_JAR=OFF \
  -DSDL_OFFSCREEN=ON -DSDL_OPENGLES=ON -DSDL_OPENGL=ON -DSDL_VULKAN=OFF -DSDL_GPU=OFF \
  -DSDL_JOYSTICK=OFF -DSDL_HIDAPI=OFF -DSDL_HAPTIC=OFF -DSDL_SENSOR=OFF \
  -DSDL_AUDIO=OFF -DSDL_CAMERA=OFF -DSDL_DIALOG=OFF -DSDL_TRAY=OFF -DSDL_PROCESS=OFF > "$WORK/cmake.log"
cmake --build "$WORK/out" --parallel > "$WORK/build.log"

mkdir -p "$(dirname "$OUT")"
cp "$WORK/out/libSDL3.so" "$OUT"
echo "Built $OUT from SDL $SDL_TAG"
