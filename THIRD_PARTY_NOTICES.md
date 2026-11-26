# Third-party notices

OpenCraft is built from these projects. Each one keeps its own licence.

## Source code in this repository

| Folder | Project | Licence | Upstream | Changes |
|---|---|---|---|---|
| `pojlib/` | Pojlib (launcher library) | LGPL-3.0 | [QuestCraftPlusPlus/Pojlib](https://github.com/QuestCraftPlusPlus/Pojlib) at `0e22a02` | [`pojlib/MODIFICATIONS.md`](pojlib/MODIFICATIONS.md) |
| `wrapper/` | QCXR-XR-Wrapper (Unity headset app) | LGPL-3.0 | [QuestCraftPlusPlus/QCXR-XR-Wrapper](https://github.com/QuestCraftPlusPlus/QCXR-XR-Wrapper) at `5aeb178` | [`wrapper/MODIFICATIONS.md`](wrapper/MODIFICATIONS.md) |

Pojlib builds into its own library (`Pojlib-release.aar`), which the Unity app loads. You can replace it with your own build, as [BUILDING.md](BUILDING.md) explains.

## Bundled in the app

| Component | Licence | Source |
|---|---|---|
| MobileGlues (OpenGL on GLES renderer) | LGPL-2.1 | [MobileGL-Dev/MobileGlues](https://github.com/MobileGL-Dev/MobileGlues) |
| LWJGL 3 (Java classes and Android natives) | BSD-3-Clause | [LWJGL/lwjgl3](https://github.com/LWJGL/lwjgl3), via [QuestCraftPlusPlus/lwjgl3](https://github.com/QuestCraftPlusPlus/lwjgl3) |
| GLFW stand-in classes (`lwjgl-glfw-classes.jar`) | LGPL-3.0 | [PojavLauncher](https://github.com/PojavLauncherTeam/PojavLauncher) |
| OpenXR loader | Apache-2.0 | [KhronosGroup/OpenXR-SDK-Source](https://github.com/KhronosGroup/OpenXR-SDK-Source) |
| OpenAL Soft | LGPL-2.0 | [kcat/openal-soft](https://github.com/kcat/openal-soft) |
| JNA | LGPL-2.1 or Apache-2.0 | [java-native-access/jna](https://github.com/java-native-access/jna) |
| sqlite-jdbc | Apache-2.0 | [xerial/sqlite-jdbc](https://github.com/xerial/sqlite-jdbc) |
| Gson, Guava | Apache-2.0 | [google/gson](https://github.com/google/gson), [google/guava](https://github.com/google/guava) |
| Apache Commons IO, Codec, Math | Apache-2.0 | [commons.apache.org](https://commons.apache.org) |
| AndroidX Core and Annotation | Apache-2.0 | [developer.android.com/jetpack/androidx](https://developer.android.com/jetpack/androidx) |
| MSAL4J | MIT | [AzureAD/microsoft-authentication-library-for-java](https://github.com/AzureAD/microsoft-authentication-library-for-java) |
| android_gamepad_remapper | LGPL-3.0 | [Mathias-Boulay/android_gamepad_remapper](https://github.com/Mathias-Boulay/android_gamepad_remapper) |
| Newtonsoft.Json | MIT | [JamesNK/Newtonsoft.Json](https://github.com/JamesNK/Newtonsoft.Json) |
| unity.webp | MIT | [netpyoung/unity.webp](https://github.com/netpyoung/unity.webp) |
| Unity Engine and Unity packages (XR Interaction Toolkit, OpenXR, TextMesh Pro, …) | Unity Terms of Service / Unity Companion License | [unity.com](https://unity.com) |
| `pojlib/libs/unity-classes.jar` (compile-time only; the app uses Unity's own copy) | Unity Terms of Service | Unity Technologies |

## Downloaded at runtime

| Component | Licence | Source |
|---|---|---|
| Java runtime (JRE 21) | GPL-2.0 with Classpath Exception (OpenJDK) | [QuestCraftPlusPlus/android-openjdk-build-multiarch](https://github.com/QuestCraftPlusPlus/android-openjdk-build-multiarch) |
| Fabric Loader | Apache-2.0 | [FabricMC/fabric-loader](https://github.com/FabricMC/fabric-loader) |
| Vivecraft | LGPL-3.0 | [QuestCraftPlusPlus/VivecraftMod](https://github.com/QuestCraftPlusPlus/VivecraftMod) |
| Fabric API and the default mods | each mod's own licence | listed in [`pojlib/mods.json`](pojlib/mods.json), from [Modrinth](https://modrinth.com) |
| The game itself | Mojang | you need your own copy; it downloads from Mojang when you sign in |

## Not included

| Component | Why | What OpenCraft does instead |
|---|---|---|
| LightThinWrapper | PolyForm Shield licence | renders with MobileGlues |
| PICO Unity OpenXR SDK | its licence forbids redistribution | Meta Quest controller profiles; no Pico headset support |
| "SkySeries Freebie" skybox | Unity Asset Store licence | Unity's built-in procedural sky |
| The game's own textures in the lobby | Mojang's copyright | loaded at runtime from the player's installed game |
