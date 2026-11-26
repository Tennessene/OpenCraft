# Building OpenCraft from source

OpenCraft 6.0.0 is based on QuestCraft 6.0.0. This repo pins the exact source that QuestCraft 6.0.0 (released 31 May 2025,
`QCXR-6.0.0.apk`) was built from:

| Part | Repo | Pinned commit | Why this commit |
|---|---|---|---|
| Launcher library | [Pojlib](https://github.com/QuestCraftPlusPlus/Pojlib) | `9bc13f4` (28 May 2025) | The `Pojlib-release.aar` committed into the wrapper on 28 May was built from it |
| Unity app / launcher | [QCXR-XR-Wrapper](https://github.com/QuestCraftPlusPlus/QCXR-XR-Wrapper) | `2d5f396` (30 May 2025) | Last wrapper commit before the release |

The upstream projects never tagged the wrapper. These pins were worked out from
commit dates, so treat them as a best match, not an official one.

## What you need

- macOS, Linux or Windows
- `git` and `git-lfs`
- **For Pojlib:** JDK 11 or 17, Android SDK (platform `android-34`,
  build-tools `30.0.3`) and NDK `26.1.10909125` (r26b)
- **For the APK:** Unity Hub, Unity **2022.3.60f1** with Android Build Support
  (tick OpenJDK and Android SDK & NDK Tools), signed in with a Unity account.
  A free Personal license works.

## Steps

```bash
git clone --recurse-submodules https://github.com/Tennessene/OpenCraft.git
cd OpenCraft
./scripts/setup.sh          # fetch pinned submodules + LFS files
./scripts/build-pojlib.sh   # optional: rebuild Pojlib-release.aar from source
./scripts/build-apk.sh      # build build/OpenCraft-6.0.0.apk with Unity
```

If you skip `build-pojlib.sh`, the APK uses the prebuilt AAR that ships in the
wrapper repo.

Install the APK with SideQuest or `adb install`. It is signed with your key
(or Unity's debug key), not the QuestCraft team's. Android won't install it
over the official app, so uninstall QuestCraft first. Uninstalling deletes its
data in `Android/data/com.qcxr.qcxr`, so back up your worlds first.

## Limits

- **Not byte-for-byte identical.** The signature, the build timestamps and
  Unity's output will differ from the official APK.
- **Some binaries are prebuilt upstream.** Pojlib commits native libraries
  (`libltw.so`, LWJGL `.so` files, `libopenxr_loader.so`) and
  `lwjgl-glfw-classes.jar`. The wrapper bundles the PICO OpenXR SDK and other
  Unity packages. They come from their own projects (LTW, LWJGL, OpenJDK) and
  are not rebuilt here.
- **The game downloads at runtime.** Minecraft, the Java runtime, Fabric,
  Vivecraft and the default mods download on first launch, as the official app
  does. Which versions you can play comes from `supportedVersions.json` and
  `mods.json` in Pojlib.
- The version string inside the APK reads `6.0.0-RC4.1`. That's how upstream
  set it at this commit.

## CI

`.github/workflows/build-pojlib.yml` builds the Pojlib AAR on every push and
uploads it as an artifact. Building the Unity APK in CI needs a Unity license
secret (for example with GameCI), so it isn't set up yet.
