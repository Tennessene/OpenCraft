// Batch-mode build entry point, copied into the wrapper by scripts/build-apk.sh.
using System;
using System.Linq;
using UnityEditor;
using UnityEditor.Build.Reporting;

public static class OpenCraftBuild
{
    public static void BuildAndroid()
    {
        string output = Environment.GetEnvironmentVariable("OPENCRAFT_APK") ?? "build/OpenCraft.apk";

        // The upstream project points at its maintainers' private keystore.
        // Use your own if given, otherwise Unity's debug key.
        string keystore = Environment.GetEnvironmentVariable("OPENCRAFT_KEYSTORE");
        if (!string.IsNullOrEmpty(keystore))
        {
            PlayerSettings.Android.useCustomKeystore = true;
            PlayerSettings.Android.keystoreName = keystore;
            PlayerSettings.Android.keystorePass = Environment.GetEnvironmentVariable("OPENCRAFT_KEYSTORE_PASS");
            PlayerSettings.Android.keyaliasName = Environment.GetEnvironmentVariable("OPENCRAFT_KEY_ALIAS");
            PlayerSettings.Android.keyaliasPass = Environment.GetEnvironmentVariable("OPENCRAFT_KEY_PASS");
        }
        else
        {
            PlayerSettings.Android.useCustomKeystore = false;
        }

        EditorUserBuildSettings.buildAppBundle = false;

        var options = new BuildPlayerOptions
        {
            scenes = EditorBuildSettings.scenes.Where(s => s.enabled).Select(s => s.path).ToArray(),
            locationPathName = output,
            target = BuildTarget.Android,
            options = BuildOptions.None,
        };

        BuildReport report = BuildPipeline.BuildPlayer(options);
        Console.WriteLine($"Build {report.summary.result}: {output} ({report.summary.totalSize} bytes)");
        EditorApplication.Exit(report.summary.result == BuildResult.Succeeded ? 0 : 1);
    }
}
