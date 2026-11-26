# Building OpenCraft

OpenCraft has two parts. Each one builds separately:

| Folder | What it is | Builds into |
|---|---|---|
| `pojlib/` | Android library that downloads Java, the game and mods, and starts the game | `Pojlib-release.aar` |
| `wrapper/` | Unity project for the headset app | the APK |

Each part is a modified copy of an upstream LGPL-3.0 project. Its `MODIFICATIONS.md` gives the upstream commit it started from and every change made since. Pojlib is a separate library inside the app, so you can swap in your own build of it. `build-pojlib.sh` shows how.

## What you need

- macOS, Linux or Windows, with `git`
- **For `pojlib/`:**
  - JDK 11 or 17
  - Android SDK with platform `android-34` and build-tools `30.0.3`
  - Android NDK `26.1.10909125` (r26b)
- **For the APK:**
  - Unity Hub
  - Unity **2022.3.62f3** (2022 LTS), with the Android Build Support module (tick OpenJDK and Android SDK & NDK Tools)
  - a Unity account signed in to Unity Hub (a free Personal license works)

## Steps

```bash
git clone https://github.com/Tennessene/OpenCraft.git
cd OpenCraft
./scripts/build-pojlib.sh   # builds pojlib/ and copies the AAR into wrapper/
./scripts/build-apk.sh      # builds build/OpenCraft.apk with Unity
```

If you skip `build-pojlib.sh`, the APK uses the prebuilt `Pojlib-release.aar` already in `wrapper/Assets/Plugins/Android/`. That file came from upstream and is older than the code in `pojlib/`.

By default the APK is signed with Unity's debug key. To use your own key, set `OPENCRAFT_KEYSTORE`, `OPENCRAFT_KEYSTORE_PASS`, `OPENCRAFT_KEY_ALIAS` and `OPENCRAFT_KEY_PASS`.

## What to expect

- **This build hasn't been tested on a headset yet.** The combination comes from upstream's newest code:
  - Pojlib `0e22a02` (July 2026)
  - wrapper `5aeb178` (March 2026)

  That code was never released as a finished version.
- **The menu room is empty.** Its scenery was removed because it used game textures. See `wrapper/MODIFICATIONS.md`.
- **Pico headsets aren't supported right now.** The PICO SDK was removed until its license is checked.
- **Some parts are prebuilt binaries, not built here:**
  - the native libraries in `pojlib/src/main/jniLibs/`
  - `pojlib/src/main/assets/lwjgl/lwjgl-glfw-classes.jar`
  - `pojlib/libs/unity-classes.jar`

  [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) says where each one comes from.
- **The game isn't in the APK.** On first launch the app downloads the game, Java, Fabric, Vivecraft and the default mods. The live lists of versions and mods come from `pojlib/` on this repo's `main` branch.

## CI

`.github/workflows/build-pojlib.yml` builds `pojlib/` on every push and uploads the AAR. CI doesn't build the Unity APK yet, because that needs a Unity license secret (for example through GameCI).
