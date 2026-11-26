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
