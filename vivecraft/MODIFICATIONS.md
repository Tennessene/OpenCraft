# Changes made for OpenCraft

This folder is a modified copy of [Vivecraft](https://github.com/Vivecraft/VivecraftMod) (LGPL-3.0; see [LICENSE.md](LICENSE.md) for the component licenses). It starts from two upstream Vivecraft branches, merged together:

- `openxr` at `13eafae1` (2026-07-27): OpenXR support for Minecraft 26.2, including the Android/Quest OpenXR pieces.
- `Multiloader-26.3` at `fee45104` (2026-11-16): the Minecraft 26.3 port.

QuestCraft's own Vivecraft fork (branch `OpenXR-26.2`) adds one commit on top of `openxr`: "Multiview Support 26.2" (`f9a4edbd`). That commit isn't included yet, because its Vulkan parts use classes Minecraft 26.3 removed. Without it, each eye is drawn in a separate pass, which costs performance on the headset.

Java files changed by OpenCraft have a `// Modified for OpenCraft` line at the top that says what changed.

## 2026-11-26

**Merge conflicts** between the two branches, resolved by hand:
- `VRRenderer.java`, `InputAction.java`, `GraphicsHelper.java`, `VulkanBackendVRMixin.java`: kept the imports from both sides.
- `MCOpenVR.java`: kept the OpenXR side, which moved the input handling into `MCVR`.
- `KeyboardKeys.java`, `MenuWorldRenderer.java`: took the 26.3 side.
- `VulkanInstanceVRMixin.java`: kept the OpenXR side's `apiVersion` field, with the 26.3 mixin target.
- `vivecraft.accesswidener`: took the 26.3 entries.
- The old `graphics/OpenGLHelper.java` and `graphics/VulkanHelper.java` were deleted. The OpenXR branch had already moved them into `graphics/opengl/` and `graphics/vulkan/`, and the 26.3 changes were applied there.

**Port to the 26.3 APIs** (OpenXR code that the 26.3 branch never touched):
- Renamed classes. 108 classes moved from `com.mojang.blaze3d.*` to `com.mojang.renderpearl.*` in 26.3. The old-to-new map came from comparing the 26.2 and 26.3 client class lists.
- `bindTexture(...)` became `setUniform(...)` on render passes.
- The GPU backend is reached through `FrontendGpuDevice.backend`.
- `textureInitCommandBuffer()` became `objectInitCommandBuffer()`.
- The desktop OpenGL handoff to OpenXR (`DeviceCompat.java`) reads the window handles from SDL3 window properties and the context from WGL/GLX, because 26.3 no longer uses GLFW.
- The left mouse button constant now comes from SDL.

**Status:** it compiles, and `./gradlew -Pplatforms=fabric :fabric:build` produces `vivecraft-26.3-1.3.18-fabric.jar`. It hasn't been run in game or on a headset.
