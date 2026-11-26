// Added for OpenCraft (2026-11-26). Original file, not derived from upstream Pojlib.
package pojlib.util;

import android.content.Context;

import java.io.File;

import pojlib.install.VersionInfo;

/**
 * Describes what a game version needs from the launcher. Versions up to 1.21.x
 * use the bundled Java 21 runtime, LWJGL 3.3 and the GLFW stand-in. 26.x
 * versions need Java 25, LWJGL 3.4 and SDL3, and draw through SDL's offscreen
 * driver while Vivecraft sends the frames to the headset.
 */
public final class GameRuntime {
    /** Java versions at or above this use the 26.x launch path. */
    private static final int SDL_ERA_JAVA = 25;

    private static final String JRE25_URL =
            "https://github.com/AngelAuraMC/angelauramc-openjdk-build/releases/download/download_jre25/jre25-android-arm64.tar.xz";

    public final int javaMajor;
    public final boolean usesSdl;

    private GameRuntime(int javaMajor) {
        this.javaMajor = javaMajor;
        this.usesSdl = javaMajor >= SDL_ERA_JAVA;
    }

    /** Works out the runtime for a vanilla version's metadata. Missing data means the older path. */
    public static GameRuntime forVersion(VersionInfo vanilla) {
        int major = (vanilla != null && vanilla.javaVersion != null) ? vanilla.javaVersion.majorVersion : 21;
        return new GameRuntime(major);
    }

    /** Folder the Java runtime for this version is unpacked into. */
    public File jreHome(Context ctx) {
        return new File(ctx.getFilesDir(), usesSdl ? "runtimes/JRE25" : "runtimes/JRE");
    }

    /** Download for the runtime, or null when the existing JRE.zip download applies. */
    public String jreTarXzUrl() {
        return usesSdl ? JRE25_URL : null;
    }

    /** Version folder name under assets/lwjgl/ holding this version's LWJGL build, or null for the GLFW stand-in jar. */
    public String lwjglAssetFolder() {
        return usesSdl ? "3.4.1" : null;
    }

    /** Where the LWJGL natives for this version are unpacked. They must live in app-private storage so they can be loaded. */
    public File lwjglNativesDir(Context ctx) {
        return new File(ctx.getFilesDir(), "lwjgl-" + lwjglAssetFolder() + "-natives");
    }
}
