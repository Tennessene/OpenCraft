# Third-party notices

OpenCraft is built from the components below, and each keeps its own license. "Bundled" means it ships inside the APK. "Downloaded at runtime" means the app fetches it on the headset and it isn't in the APK.

**How licenses were checked.** Each license was read from the project's own repository, using the GitHub license API or the license file itself. **UNVERIFIED** means it couldn't be confirmed. Those entries need checking before any release.

Last updated: 2026-11-26.

## Source projects (git submodules on `main`)

| Component | Where | License | Source |
|---|---|---|---|
| Pojlib (launcher library) | `pojlib/`, bundled | LGPL-3.0 | https://github.com/QuestCraftPlusPlus/Pojlib |
| QCXR-XR-Wrapper (Unity headset app) | `wrapper/`, bundled | LGPL-3.0 | https://github.com/QuestCraftPlusPlus/QCXR-XR-Wrapper |

## Prebuilt binaries committed inside Pojlib (pinned commit `9bc13f4`)

| Component | File(s) | License | Source |
|---|---|---|---|
| **LightThinWrapper (LTW)** | `src/main/jniLibs/arm64-v8a/libltw.so` | **PolyForm Shield (as you stated). UNVERIFIED by me, because the repository isn't public. See the open issue below.** | https://github.com/PojavLauncherTeam (no public repo found) |
| LWJGL 3 natives | `liblwjgl*.so` | BSD-3-Clause | https://github.com/QuestCraftPlusPlus/lwjgl3 (fork of https://github.com/LWJGL/lwjgl3) |
| LWJGL GLFW stand-in + LWJGL classes | `src/main/assets/lwjgl/lwjgl-glfw-classes.jar` | BSD-3-Clause (LWJGL); stand-in classes UNVERIFIED (likely LGPL-3.0 from PojavLauncher) | https://github.com/PojavLauncherTeam/PojavLauncher |
| OpenXR loader | `src/main/jni/libopenxr_loader.so` | Apache-2.0 | https://github.com/KhronosGroup/OpenXR-SDK-Source |
| OpenAL Soft | `libopenal.so` | LGPL-2.0 (the "Library GPL v2" text in COPYING). Whether it's "or later" is UNVERIFIED | https://github.com/kcat/openal-soft |
| JNA native dispatch | `libjnidispatch.so` | LGPL-2.1 or Apache-2.0 (dual) | https://github.com/java-native-access/jna |
| sqlite-jdbc native | `libsqlitejdbc.so` | Apache-2.0 | https://github.com/xerial/sqlite-jdbc |
| OpenJDK AWT libraries | `libawt_headless.so`, `libawt_xawt.so` | GPL-2.0 with Classpath Exception (UNVERIFIED for these specific builds) | https://github.com/PojavLauncherTeam |
| LLVM libc++ (Android NDK) | `libc++_shared.so` | Apache-2.0 WITH LLVM-exception (UNVERIFIED) | https://android.googlesource.com/toolchain/llvm-project |
| Unity Android classes | `libs/unity-classes.jar` | **Proprietary Unity license. UNVERIFIED whether it may be redistributed.** | Unity Technologies |

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

## Inside the Unity wrapper (pinned commit `2d5f396`)

| Component | License | Source |
|---|---|---|
| Unity Engine (build tool; its runtime ends up in the APK) | Proprietary, Unity Terms of Service | https://unity.com |
| Unity packages (XR Interaction Toolkit, OpenXR plugin, TextMesh Pro, …) | Unity Companion License (UNVERIFIED for each package) | https://unity.com |
| PICO Unity OpenXR Integration SDK 1.3.0 (`Packages/LocalPackages`) | **UNVERIFIED (no license file in the package)** | https://developer.picoxr.com |
| unity.webp | MIT | https://github.com/netpyoung/unity.webp |
| Crowdin Unity plugin | UNVERIFIED | https://crowdin.com |
| Newtonsoft.Json 13.0.3 | MIT | https://github.com/JamesNK/Newtonsoft.Json |
| System.Runtime.CompilerServices.Unsafe | MIT (UNVERIFIED) | https://github.com/dotnet/runtime |
| "SkySeries Freebie" and "WinterLodge" art assets | **UNVERIFIED. They look like Unity Asset Store assets, whose license may not allow redistribution in source form** | unknown |
| QuestCraft product name and icons | **Belongs to the QuestCraft team. Must be replaced before release.** | `ProjectSettings/ProjectSettings.asset` |

## Downloaded at runtime (not in the APK)

| Component | License | Source |
|---|---|---|
| Java runtime (JRE 21/22) | GPL-2.0 with Classpath Exception (OpenJDK). The build scripts repo has no license file (UNVERIFIED) | https://github.com/QuestCraftPlusPlus/android-openjdk-build-multiarch |
| Fabric Loader | Apache-2.0 | https://github.com/FabricMC/fabric-loader |
| Vivecraft | LGPL-3.0 (its own LICENSE.md also lists component licenses) | https://github.com/Vivecraft/VivecraftMod |
| Fabric API and the default performance mods | Various. Each one is listed in `pojlib/mods.json` (UNVERIFIED per mod) | https://modrinth.com |
| The game itself | Proprietary (Mojang). Never bundled: you need your own copy | https://www.minecraft.net |

## OpenCraft's own files

These are original to this repository: `banner.svg`, `README.md`, `BUILDING.md`, `scripts/`, `tools/unity/OpenCraftBuild.cs`, `.github/`. They don't have a license yet, and it's up to you to choose one.

## Open licensing issues

1. **LightThinWrapper is bundled.** The pinned Pojlib commit ships `libltw.so`, and the APK built from `main` would include it.
2. **The git history contains QuestCraft's README and images.** The QuestCraft repository has no license. Its files were removed from the current tree, but they're still in this repo's history and old tags.
3. **The wrapper uses QuestCraft branding.** Its product name and icons need replacing.
4. **Unity Asset Store and PICO SDK assets** in the wrapper have unverified redistribution terms.
5. **`unity-classes.jar`** is proprietary Unity code committed in Pojlib.
