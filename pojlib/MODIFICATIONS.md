# Changes made for OpenCraft

This folder is a modified copy of [Pojlib](https://github.com/QuestCraftPlusPlus/Pojlib), based on upstream commit `0e22a02` ("Fix kilt", branch `QuestCraft-6.0.1`, 2026-07-30). It stays under the GNU LGPL v3 in [LICENSE](LICENSE). Java files that were changed have a `// Modified for OpenCraft` line at the top.

## 2026-11-26

- `src/main/java/pojlib/util/Constants.java`, `APIHandler.java`, `InstanceHandler.java`: the live version and mod lists (`supportedVersions.json`, `mods.json`, `devmods.json`) are read from `pojlib/` on the OpenCraft repo's `main` branch instead of the upstream Pojlib branch.
- `src/main/java/pojlib/util/JREUtils.java`: the client brand passed to the game is `OpenCraft`.
- `src/main/java/pojlib/util/download/DownloadUtils.java`: downloads send an OpenCraft User-Agent.
- `src/main/java/pojlib/API.java`, `util/MCOptionUtils.java`, `util/json/MinecraftInstances.java`: log messages and tags say OpenCraft.
- `src/main/assets/servers.dat`: the preset server list is now empty (it used to add the upstream project's server).
- Native libraries (`src/main/jni/libopenxr_loader.so`, `src/main/jniLibs/arm64-v8a/*.so`) are committed as regular files, not Git LFS pointers. Each one was downloaded from upstream LFS and checked against the SHA-256 recorded in its pointer. `.gitattributes` no longer routes `*.so` through LFS.
- Removed `.gitmodules`, which pointed at an upstream repo nothing here uses, and `.github/`, upstream's CI. OpenCraft's CI lives at the repository root.
- `README.md`: added a fork note at the top and removed the upstream CI badge. The original text and credits are kept.

## 2026-11-26, `mc-26.3` branch: support for 26.x game versions

Game versions that ask for Java 25 in their metadata (26.x) launch differently from 1.21.x and earlier:
- They get a Java 25 runtime in `runtimes/JRE25`, downloaded as a `.tar.xz` from AngelAuraMC's OpenJDK builds.
- They use LWJGL 3.4.1 with SDL3 bindings instead of the GLFW stand-in.
- They draw through SDL3's offscreen video driver, with MobileGlues as both the GL and EGL library.

Older versions behave exactly as before.

- **New, original files:**
  - `src/main/java/pojlib/util/GameRuntime.java`: decides the runtime for each version.
  - `src/main/java/pojlib/util/TarXz.java`: unpacks `.tar.xz` archives.
  - `scripts/build-sdl3.sh`: builds `libSDL3.so` from SDL `release-3.4.20` with the offscreen driver.
- `src/main/java/pojlib/install/VersionInfo.java`: reads `javaVersion` from version metadata.
- `src/main/java/pojlib/install/Installer.java`:
  - New `installJVM(activity, force, GameRuntime)`.
  - `installLibraries` no longer adds the GLFW stand-in jar itself, because `installLWJGL` now decides.
- `src/main/java/pojlib/UnityPlayerActivity.java`: new `installLWJGL(activity, GameRuntime)`. It unpacks `assets/lwjgl/3.4.1/*.jar` and its natives into app-private storage.
- `src/main/java/pojlib/InstanceHandler.java`: passes the version's runtime to `installLWJGL`.
- `src/main/java/pojlib/util/JREUtils.java`:
  - The Java home, the SDL environment (`SDL_VIDEO_DRIVER`, `SDL_OPENGL_LIBRARY`, `SDL_EGL_LIBRARY`) and the LWJGL arguments (`org.lwjgl.sdl.libname`, `org.lwjgl.system.allocator`, `org.lwjgl.librarypath`) follow the version.
  - The runtime is installed before the environment reads it.
- `src/main/java/pojlib/util/Constants.java`: live lists are read from the `mc-26.3` branch.
- `build.gradle`: adds commons-compress and xz-java, plus a `buildSDL3` task that runs before every build.
- `supportedVersions.json`, `mods.json`: 26.3 added. Its Vivecraft link points to an OpenCraft release that **doesn't exist yet**.
- **New prebuilt files**, from AngelAuraMC's Amethyst launcher. `SHA256SUMS` lists their checksums.
  - `src/main/assets/lwjgl/3.4.1/`: LWJGL 3.4.1 jars.
  - `src/main/assets/lwjgl/3.4.1/natives/`: arm64 natives.
  - `lwjgl-opengl.jar` is repacked from Amethyst's `lwjgl-3.4.1-merged-modules.jar`, without its `glfw` and `sdl` packages (which call into Amethyst's launcher) and its module descriptor.
- `src/main/java/pojlib/util/download/DownloadUtils.java`, `util/Constants.java`: a mod link written as `bundled:<name>` is copied from the APK's `assets/bundled/<name>` instead of downloaded. `Constants` keeps the app context for this. The 26.3 Vivecraft entry in `mods.json` now uses `bundled:vivecraft-26.3.jar`. `scripts/build-apks.sh` builds that jar from `vivecraft/` and adds it to the AAR, so nothing has to be hosted.
- `src/main/jni/input_bridge_v3.c`: in the game JVM, `JNI_OnLoad` skips the GLFW stand-in setup when there's no `org.lwjgl.glfw.GLFW` class. 26.x versions use SDL3, and without this check the game crashed as soon as LWJGL loaded.
- `src/main/java/pojlib/util/JREUtils.java`: Java 25 game versions start with `-XX:-UseNUMA`. Java 25 probes NUMA with the `get_mempolicy` system call, which Android's app sandbox forbids, so the JVM was killed with SIGSYS.
- `src/main/jni/input_bridge_v3.c`: for 26.x versions, `JNI_OnLoad` also opens `libSDL3.so` and calls `SDL_SetMainReady()`. On Android, SDL3 refuses `SDL_Init` until the app marks itself ready, which SDL's own activity normally does.
