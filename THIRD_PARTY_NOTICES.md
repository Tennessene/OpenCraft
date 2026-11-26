# Third-party notices

OpenCraft is built from the components below, and each keeps its own license. "Bundled" means it ships inside the APK. "Downloaded at runtime" means the app fetches it on the headset and it isn't in the APK.

**How licenses were checked.** Each license was read from the project's own repository, using the GitHub license API or the license file itself. **UNVERIFIED** means it couldn't be confirmed, and those entries need checking before any release.

Last updated: 2026-11-26.

## Modified upstream code in this repository

| Component | Folder | License | Based on | Changes |
|---|---|---|---|---|
| Pojlib (launcher library) | `pojlib/`, bundled as a separate `.aar` library | LGPL-3.0 | https://github.com/QuestCraftPlusPlus/Pojlib at `0e22a02` | `pojlib/MODIFICATIONS.md` |
| QCXR-XR-Wrapper (Unity headset app) | `wrapper/`, bundled | LGPL-3.0 (its LICENSE file; its README badge says GPLv3, which is UNVERIFIED as a conflict) | https://github.com/QuestCraftPlusPlus/QCXR-XR-Wrapper at `5aeb178` | `wrapper/MODIFICATIONS.md` |

## Prebuilt binaries inside `pojlib/` (bundled)

| Component | File(s) | License | Source |
|---|---|---|---|
| MobileGlues (OpenGL-on-GLES renderer) | `src/main/jniLibs/arm64-v8a/libmobileglues.so`, `libmobileglues_info_getter.so` | LGPL-2.1 | https://github.com/MobileGL-Dev/MobileGlues |
| LWJGL 3 natives | `liblwjgl*.so` | BSD-3-Clause | https://github.com/QuestCraftPlusPlus/lwjgl3 (fork of https://github.com/LWJGL/lwjgl3) |
| LMDB (inside `liblwjgl_lmdb.so`) | `liblwjgl_lmdb.so` | UNVERIFIED (probably the OpenLDAP Public License) | https://www.symas.com/lmdb |
| LWJGL classes with a GLFW stand-in | `src/main/assets/lwjgl/lwjgl-glfw-classes.jar` | BSD-3-Clause (LWJGL). The stand-in classes are UNVERIFIED, probably LGPL-3.0 from PojavLauncher | https://github.com/PojavLauncherTeam/PojavLauncher |
| OpenXR loader | `src/main/jni/libopenxr_loader.so` | Apache-2.0 | https://github.com/KhronosGroup/OpenXR-SDK-Source |
| OpenAL Soft | `libopenal.so` | LGPL-2.0 (the "Library GPL v2" text in COPYING). Whether it's "or later" is UNVERIFIED | https://github.com/kcat/openal-soft |
| JNA native dispatch | `libjnidispatch.so` | LGPL-2.1 or Apache-2.0 (dual) | https://github.com/java-native-access/jna |
| sqlite-jdbc native | `libsqlitejdbc.so` | Apache-2.0 | https://github.com/xerial/sqlite-jdbc |
| Unity Android classes (compile-time only) | `libs/unity-classes.jar` | **Proprietary Unity license. Whether it may be redistributed is UNVERIFIED** | Unity Technologies |

Built from `pojlib/src/main/jni` when you build Pojlib: `libpojavexec.so`, `libvloader.so`, `libjrelauncher.so`, `libistdio.so`, `libawt_headless.so`, `libawt_xawt.so`. These are Pojlib's own sources (LGPL-3.0). Some may come from PojavLauncher or OpenJDK (UNVERIFIED per file). The NDK adds `libc++_shared.so`: Apache-2.0 WITH LLVM-exception (UNVERIFIED).

## Java libraries Pojlib depends on (bundled)

| Component | License | Source |
|---|---|---|
| Gson | Apache-2.0 | https://github.com/google/gson |
| Guava | Apache-2.0 | https://github.com/google/guava |
| Apache Commons IO / Codec / Math3 | Apache-2.0 | https://commons.apache.org |
| JetBrains annotations | Apache-2.0 | https://github.com/JetBrains/java-annotations |
| AndroidX Core / Annotation | Apache-2.0 (UNVERIFIED) | https://developer.android.com/jetpack/androidx |
| MSAL4J | MIT | https://github.com/AzureAD/microsoft-authentication-library-for-java |
| org.json (20220924) | UNVERIFIED (GitHub reports "Other"; this version may be under the JSON License) | https://github.com/stleary/JSON-java |
| android_gamepad_remapper | LGPL-3.0 | https://github.com/Mathias-Boulay/android_gamepad_remapper |

## Inside `wrapper/`

| Component | License | Source |
|---|---|---|
| Unity Engine (the build tool; its runtime ends up in the APK) | Proprietary, Unity Terms of Service | https://unity.com |
| Unity packages (XR Interaction Toolkit, OpenXR plugin, TextMesh Pro, …) | Unity Companion License (UNVERIFIED per package) | https://unity.com |
| unity.webp | MIT | https://github.com/netpyoung/unity.webp |
| Crowdin Unity plugin | UNVERIFIED | https://crowdin.com |
| Newtonsoft.Json 13.0.3 | MIT | https://github.com/JamesNK/Newtonsoft.Json |
| System.Runtime.CompilerServices.Unsafe | MIT (UNVERIFIED) | https://github.com/dotnet/runtime |
| Prebuilt `Assets/Plugins/Android/Pojlib-release.aar` | LGPL-3.0 (an older upstream build of Pojlib). It contains the same kinds of native libraries as above | upstream wrapper |
| Other art in `Assets/Resources`, `Assets/Prefabs` and similar, not replaced by OpenCraft | UNVERIFIED (assumed part of the LGPL-3.0 wrapper) | upstream wrapper |

## Downloaded at runtime (not in the APK)

| Component | License | Source |
|---|---|---|
| Java runtime (JRE 21) | GPL-2.0 with Classpath Exception (OpenJDK). The build scripts repo has no license file (UNVERIFIED) | https://github.com/QuestCraftPlusPlus/android-openjdk-build-multiarch |
| Fabric Loader | Apache-2.0 | https://github.com/FabricMC/fabric-loader |
| Vivecraft (the upstream project's builds) | LGPL-3.0 (its LICENSE.md also lists component licenses) | https://github.com/QuestCraftPlusPlus/VivecraftMod |
| Fabric API, ModernFix and the default performance mods (from Modrinth) | Various, one per mod (UNVERIFIED each). Listed in `pojlib/mods.json` | https://modrinth.com |
| The game itself | Proprietary (Mojang). Never bundled: you need your own copy | https://www.minecraft.net |

## Removed from OpenCraft

| Component | Why | When |
|---|---|---|
| LightThinWrapper (`libltw.so`) | PolyForm Shield. Replaced by MobileGlues, using Pojlib code that had already switched | 2026-11-26 |
| PICO Unity OpenXR Integration SDK 1.3.0 | License couldn't be verified | 2026-11-26 |
| "SkySeries Freebie" skybox | Looked like a Unity Asset Store asset; redistribution terms couldn't be verified | 2026-11-26 |
| "WinterLodge" and "QCWorld" menu scenery, plus its baked lightmaps | Exported from the game, using its block textures | 2026-11-26 |
| The upstream project's name, icon, wordmark, EULA, server list and links | Branding that belongs to the upstream project | 2026-11-26 |

## OpenCraft's own files

These are original to this repository: `banner.svg`, `README.md`, `BUILDING.md`, `THIRD_PARTY_NOTICES.md`, `scripts/`, `tools/`, `.github/`, `wrapper/OpenCraft/`, `wrapper/Assets/OpenCraft/`, the replacement images listed in `wrapper/MODIFICATIONS.md`, and the empty `pojlib/src/main/assets/servers.dat`. They don't have a license yet. That's your decision.

## Open licensing questions

1. **`unity-classes.jar`** is proprietary Unity code committed in `pojlib/libs/`.
2. **The JRE 21 download** comes from an upstream repository that has no license file. The OpenJDK license should cover the binaries, but this isn't confirmed.
3. **Mods downloaded at runtime** each have their own license. They aren't redistributed here, only linked from `mods.json`.
4. **The wrapper's README badge (GPLv3) and its LICENSE file (LGPL-3.0) disagree.**
5. **Unverified art** in the wrapper that wasn't replaced (see the table above).
