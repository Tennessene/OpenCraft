# Changes made for OpenCraft

This folder is OpenCraft's copy of [QCXR-XR-Wrapper](https://github.com/QuestCraftPlusPlus/QCXR-XR-Wrapper), based on upstream commit `5aeb178` ("Callback fixes", 2026-03-16). It's licensed under the GNU LGPL v3 in [LICENSE](LICENSE). C# files that were changed start with a `// Modified for OpenCraft` comment. The other changes are listed below.

## Name and links

- `ProjectSettings/ProjectSettings.asset`:
  - The product, company and project names are now "OpenCraft".
  - The Android app ID is `io.github.tennessene.opencraft`.
  - The upstream signing keystore is cleared. Builds use your own key, or Unity's debug key if you don't set one.
- `ProjectSettings/AndroidResolverDependencies.xml`, `Assets/Resources/PicoSdkPCConfig.json`: the new app ID.
- `Assets/Scripts/*.cs`:
  - Web requests identify themselves as OpenCraft.
  - Release notes come from the OpenCraft repo.
  - The community buttons open OpenCraft's GitHub page. Their method names are unchanged, because scene buttons bind to them.
  - Storage paths follow the app ID.
- `Assets/Scenes/Main.unity`, `Assets/Resources/Crowdin/CrowdinTranslations.asset`: these texts use OpenCraft wording:
  - the welcome screen
  - the licence notice and agreement
  - the open-source notice
  - the support hint
  - the sample changelog
  - the placeholder username
- `Assets/Resources/Materials/export202201252311597020.png` (app icon), `Assets/Resources/Pojav_x_Vivecraft.png` (wordmark): OpenCraft's own icon and wordmark.
- `Assets/Resources/UI/Discord-Symbol-White.png`, `Assets/Resources/UI/X Logo.png`: plain chat and link symbols, since those buttons now open GitHub.
- `OpenCraft/branding/make_images.py`: draws the four images above.
- `README.md`: new title and introduction. The original credits are kept.

## Lobby

- The lobby scenery (`Assets/WinterLodge`, `Assets/QCWorld`) and its baked lighting (`Assets/Scenes/Main`) are upstream's.
- **Game textures are loaded from the player's game.** Some lobby textures were exported from the game itself. Those 122 files are placeholders here, named `gametex.<path>.png`: same size as the originals, filled with each one's average colour. `Assets/OpenCraft/GameTextureLoader.cs` swaps in the real textures from the newest game version the launcher has downloaded. `OpenCraft/branding/make_game_texture_placeholders.py` made the placeholders.
- **Sky:** `Assets/OpenCraft/OpenCraftSky.mat` uses Unity's built-in procedural sky. Upstream used the "SkySeries Freebie" skybox pack, which isn't included because its licence doesn't allow redistribution.

## Headset support

- **PICO SDK not included.** Upstream bundles PICO's Unity OpenXR SDK, whose licence forbids redistribution. So:
  - Pico headsets aren't supported.
  - `Packages/manifest.json`, `Packages/packages-lock.json` and `ProjectSettings/EditorBuildSettings.asset` no longer reference it.
- **OpenXR loader.** `Assets/OpenCraft/OpenCraftLoaderFeature.cs` is an OpenXR feature that only declares that Android brings its own loader. This makes Unity leave its copy out, and Pojlib's loader is used. Upstream got the same effect from PICO's feature.
- **Controllers and the loader feature at build time.** OpenCraft's build hook (`tools/unity/OpenCraftBuild.cs`, at the repo root) enables that feature. It also turns on Unity's Meta Quest Touch, Touch Plus and Touch Pro controller profiles, which replace the PICO controller profiles upstream relied on.

## Android build

- `Assets/Plugins/Android/mainTemplate.gradle`:
  - Lists every library Pojlib needs at runtime, because an AAR doesn't carry its dependencies. Upstream's list was missing Gson, so the launcher crashed on start.
  - Versions are chosen so Unity 2022.3's dexer (D8 4.0.52) can process them: MSAL4J 1.17.0, Commons Compress 1.21, XZ 1.9, no `error_prone_annotations`.
- `Assets/Plugins/Android/gradleTemplate.properties`: Jetifier skips the Pojlib AAR. It can't read the Java 25 classes Pojlib carries for 26.x versions, and Pojlib has no old support-library code to rewrite anyway.
- `.gitignore`: the build backup folder uses the new product name.

## Start-up fixes

- `Assets/Scripts/JNIStorage.cs`: runs first (`[DefaultExecutionOrder(-100)]`), so Pojlib, the Android activity and the config are ready before other scripts use them. Before this, sign-in could start before Pojlib was set up.
- `Assets/Scripts/ConfigHandler.cs`: an empty or unreadable `launcher.conf` gets replaced with defaults instead of crashing start-up, which also stopped versions and instances from loading.
- `Assets/Scripts/LoginHandler.cs`: no longer creates an empty `launcher.conf` (the cause of the above), and copes when the config is missing.
- `Assets/Scripts/UIHandler.cs`, `Assets/Scripts/WindowHandler.cs`: the agreement's Continue button unlocks once the text is scrolled to the end, or straight away if it fits. Upstream checked a fixed scroll offset sized for its long EULA.
