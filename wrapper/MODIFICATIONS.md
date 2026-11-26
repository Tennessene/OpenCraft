# Changes made for OpenCraft

This is a modified copy of [QCXR-XR-Wrapper](https://github.com/QuestCraftPlusPlus/QCXR-XR-Wrapper), based on upstream commit `5aeb178` ("Callback fixes", 2026-03-16). It stays under the GNU LGPL v3 in [LICENSE](LICENSE).

The C# scripts that changed carry a `// Modified for OpenCraft` line at the top. Unity scene, asset and image files can't hold such a comment, so they're listed here instead.

## 2026-11-26

**Branding and links**
- `ProjectSettings/ProjectSettings.asset`:
  - The product, company and project names are now "OpenCraft".
  - The Android app ID is `io.github.tennessene.opencraft`.
  - The upstream signing keystore setting is cleared, so builds use your own key or Unity's debug key.
- `ProjectSettings/AndroidResolverDependencies.xml` and `Assets/Resources/PicoSdkPCConfig.json`: new app ID.
- `Assets/Scripts/*.cs` (11 files):
  - Web requests identify themselves as OpenCraft.
  - Release notes come from the OpenCraft repo.
  - The Discord, X and website buttons open the OpenCraft GitHub page. The method names are unchanged, because the scene's buttons bind to them.
  - Two storage paths now follow the app ID.
- `Assets/Scenes/Main.unity` and `Assets/Resources/Crowdin/CrowdinTranslations.asset`: these texts were replaced with OpenCraft's own wording:
  - the welcome screen
  - the end-user license agreement
  - the open-source notice
  - the agree statement
  - the Discord invite line
  - the support hint
  - the sample changelog
  - the placeholder username
- `README.md`: new title and introduction. The original credits are kept.
- `.gitignore`: the build backup folder pattern uses the new product name.

**Images replaced with original artwork** (same file paths, sizes and Unity GUIDs). They're drawn by `OpenCraft/branding/make_images.py`:
- `Assets/Resources/Materials/export202201252311597020.png` (app icon)
- `Assets/Resources/Pojav_x_Vivecraft.png` (wordmark)
- `Assets/Resources/UI/Minecraft.png` (launch button)
- `Assets/Resources/UI/Background.png`
- `Assets/Resources/questerBackground.png`
- `Assets/Resources/magmapillar.png`
- `Assets/Resources/trapdoorside.png`
- `Assets/Resources/SkinResources/skin.png` (default player skin)
- `Assets/Resources/UI/Discord-Symbol-White.png` and `Assets/Resources/UI/X Logo.png` (now plain chat and link symbols)

**Removed**
- `Assets/QCWorld/` and `Assets/WinterLodge/`. The menu-room scenery was exported from the game and used its block textures.
- `Assets/SkySeries Freebie/`. This skybox pack's redistribution terms couldn't be verified.
- `Packages/LocalPackages/PICO Unity OpenXR Integration SDK-1.3.0/`. Its license couldn't be verified, so it's gone from `Packages/manifest.json`, `Packages/packages-lock.json` and `ProjectSettings/EditorBuildSettings.asset` as well. Without it, Pico headsets aren't supported. Quest headsets aren't affected.
- `Assets/Scenes/Main/`. These were baked lightmaps for the removed scenery. The scene's lighting-data reference was cleared to match.

**Added**
- `Assets/OpenCraft/OpenCraftSky.mat`: a sky using Unity's built-in procedural sky shader, now set as the scene's skybox.
- `OpenCraft/branding/make_images.py`: generates the images listed above.

The menu scene has **not** been opened in Unity since these changes. Objects that pointed at the removed scenery now have missing references and won't draw. The menu should still load, but it will look empty until new scenery is added.
