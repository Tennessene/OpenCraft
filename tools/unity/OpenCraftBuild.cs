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

        // Optional per-build identity, so builds from different branches can be installed side by side
        string appId = Environment.GetEnvironmentVariable("OPENCRAFT_APP_ID");
        if (!string.IsNullOrEmpty(appId))
            PlayerSettings.SetApplicationIdentifier(BuildTargetGroup.Android, appId);
        string appName = Environment.GetEnvironmentVariable("OPENCRAFT_APP_NAME");
        if (!string.IsNullOrEmpty(appName))
            PlayerSettings.productName = appName;

        // Only one OpenXR loader may ship: the launcher library's. Turning on this feature
        // tells Unity's OpenXR package to leave its own loader out (see OpenCraftLoaderFeature).
        UnityEditor.XR.OpenXR.Features.FeatureHelpers.RefreshFeatures(BuildTargetGroup.Android);
        var xrSettings = UnityEngine.XR.OpenXR.OpenXRSettings.GetSettingsForBuildTargetGroup(BuildTargetGroup.Android);
        var loaderFeature = xrSettings != null ? xrSettings.GetFeature<OpenCraft.OpenCraftLoaderFeature>() : null;
        if (loaderFeature == null)
        {
            Console.WriteLine("OpenCraft: OpenCraftLoaderFeature not found in the Android OpenXR settings");
            EditorApplication.Exit(1);
            return;
        }
        loaderFeature.enabled = true;

        // Quest controllers. Upstream only enabled PICO's controller profiles (from the PICO SDK,
        // which OpenCraft can't ship), so turn on Unity's own Meta Quest Touch profiles instead.
        var controllerProfiles = new UnityEngine.XR.OpenXR.Features.OpenXRFeature[]
        {
            xrSettings.GetFeature<UnityEngine.XR.OpenXR.Features.Interactions.OculusTouchControllerProfile>(),
            xrSettings.GetFeature<UnityEngine.XR.OpenXR.Features.Interactions.MetaQuestTouchPlusControllerProfile>(),
            xrSettings.GetFeature<UnityEngine.XR.OpenXR.Features.Interactions.MetaQuestTouchProControllerProfile>(),
        };
        foreach (var profile in controllerProfiles)
        {
            if (profile == null)
            {
                Console.WriteLine("OpenCraft: a Meta Quest controller profile is missing from the Android OpenXR settings");
                EditorApplication.Exit(1);
                return;
            }
            profile.enabled = true;
        }
        EditorUtility.SetDirty(xrSettings);
        AssetDatabase.SaveAssets();

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
