// Modified for OpenCraft (2026-11-26): merged imports; applied 26.3 class renames to mixin targets.
package org.vivecraft.mixin.client_vr.blaze3d.vulkan;

import com.llamalad7.mixinextras.injector.wrapoperation.Operation;
import com.llamalad7.mixinextras.injector.wrapoperation.WrapOperation;
import com.llamalad7.mixinextras.sugar.Local;
import com.llamalad7.mixinextras.sugar.Share;
import com.llamalad7.mixinextras.sugar.ref.LocalRef;
import com.mojang.renderpearl.api.device.GpuDevice;
import com.mojang.renderpearl.backend.vulkan.VulkanBackend;
import com.mojang.renderpearl.backend.vulkan.VulkanPhysicalDevice;
import org.lwjgl.vulkan.VkPhysicalDevice;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.ModifyArg;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;
import com.mojang.renderpearl.backend.vulkan.VulkanBackend;
import com.mojang.renderpearl.backend.vulkan.VulkanPhysicalDevice;
import com.mojang.renderpearl.backend.vulkan.init.FeatureSet;
import org.vivecraft.client_vr.ClientDataHolderVR;
import org.vivecraft.client_vr.render.helpers.graphics.vulkan.VulkanStaticHelper;

import java.util.*;

@Mixin(VulkanBackend.class)
public class VulkanBackendVRMixin {
    @ModifyArg(method = "createDevice(Lcom/mojang/renderpearl/api/device/GpuDebugOptions;)Lcom/mojang/renderpearl/api/device/GpuDevice;", at = @At(value = "INVOKE", target = "Lcom/mojang/renderpearl/backend/vulkan/init/FeatureSet;<init>(Ljava/lang/String;Ljava/util/Collection;)V"), index = 1)
    private Collection<FeatureSet> vivecraft$vrDeviceExtensions(
        Collection<FeatureSet> enabledFeatureSets, @Local VulkanPhysicalDevice physicalDevice,
        @Local(ordinal = 0) Set<String> deviceExtensions)
    {
        if (!ClientDataHolderVR.getInstance().vrSettings.requiredVulkanDeviceExtensions.isEmpty()) {
            // check that all extensions are supported before enabling anything
            String[] neededExtensions = ClientDataHolderVR.getInstance().vrSettings.requiredVulkanDeviceExtensions.split(
                " ");
            List<String> missingExtensions = new ArrayList<>();
            for (String extension : neededExtensions) {
                if (!physicalDevice.hasDeviceExtension(extension)) {
                    missingExtensions.add(extension);
                }
            }
            if (missingExtensions.isEmpty()) {
                // all available, enable them
                enabledFeatureSets.add(
                    new FeatureSet("VR Extensions", new HashSet<>(Arrays.asList(neededExtensions)), Set.of()));
            }
        }
        return enabledFeatureSets;
    }

    @WrapOperation(method = "findPhysicalDevice", at = @At(value = "INVOKE", target = "Lcom/mojang/renderpearl/backend/vulkan/VulkanBackend;isDeviceSuitable(Lorg/lwjgl/vulkan/VkPhysicalDevice;)Z"))
    private static boolean vivecraft$preferVRGpuCapture(
        VkPhysicalDevice vkPhysicalDevice, Operation<Boolean> original,
        @Share("vrVkDevice") LocalRef<VkPhysicalDevice> vrVkDevice)
    {
        boolean suitable = original.call(vkPhysicalDevice);

        String requiredDevice = ClientDataHolderVR.getInstance().vrSettings.requiredVulkanDeviceUUID;
        if (suitable && !requiredDevice.isEmpty()) {
            if (VulkanStaticHelper.getDeviceUUID(vkPhysicalDevice).equals(requiredDevice)) {
                vrVkDevice.set(vkPhysicalDevice);
            }
        }
        return suitable;
    }

    @ModifyArg(method = "findPhysicalDevice", at = @At(value = "INVOKE", target = "Lcom/mojang/renderpearl/backend/vulkan/VulkanPhysicalDevice;<init>(Lorg/lwjgl/vulkan/VkPhysicalDevice;)V"))
    private static VkPhysicalDevice vivecraft$preferVRGpuSet(
        VkPhysicalDevice vkPhysicalDevice, @Share("vrVkDevice") LocalRef<VkPhysicalDevice> vrVkDevice)
    {
        return vrVkDevice.get() != null ? vrVkDevice.get() : vkPhysicalDevice;
    }
}
