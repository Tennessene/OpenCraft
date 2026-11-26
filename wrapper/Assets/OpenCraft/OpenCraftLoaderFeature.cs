// Added for OpenCraft (2026-11-26). Original file.
//
// Unity's OpenXR package normally adds its own openxr_loader.aar to Android builds.
// OpenCraft's launcher library (Pojlib) already ships the Khronos OpenXR loader, and
// two copies of libopenxr_loader.so make the Android build fail. An enabled feature
// that declares a custom runtime loader for Android tells Unity to leave its copy out,
// so the single loader from Pojlib serves both the Unity menus and Vivecraft in game.
// The feature does nothing at runtime.

#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.XR.OpenXR.Features;
#endif
using UnityEngine.XR.OpenXR.Features;

namespace OpenCraft
{
#if UNITY_EDITOR
    [OpenXRFeature(
        UiName = "OpenCraft: use the launcher's OpenXR loader",
        Desc = "Leaves Unity's bundled OpenXR loader out of Android builds, because the launcher library already ships one.",
        Company = "OpenCraft",
        Version = "1.0.0",
        BuildTargetGroups = new[] { BuildTargetGroup.Android },
        CustomRuntimeLoaderBuildTargets = new[] { BuildTarget.Android },
        FeatureId = FeatureId)]
#endif
    public class OpenCraftLoaderFeature : OpenXRFeature
    {
        public const string FeatureId = "io.github.tennessene.opencraft.feature.launcherloader";
    }
}
