// Modified for OpenCraft (2026-11-26): 26.3 class renames in mixin targets.
package org.vivecraft.mixin.client_vr.blaze3d.vulkan;

import com.mojang.renderpearl.backend.vulkan.VulkanDevice;
import com.mojang.renderpearl.backend.vulkan.VulkanQueue;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Unique;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;
import org.vivecraft.client_vr.extensions.vulkan.VulkanQueueExtension;

@Mixin(VulkanQueue.class)
public class VulkanQueueVRMixin implements VulkanQueueExtension {

    @Unique
    private int vivecraft$queueIndex = -1;

    @Override
    public int vivecraft$getQueueIndex() {
        return this.vivecraft$queueIndex;
    }

    @Inject(method = "<init>(Lcom/mojang/renderpearl/backend/vulkan/VulkanDevice;II)V", at = @At("TAIL"))
    private void vivecraft$storeQueueIndex(VulkanDevice device, int queueFamilyIndex, int queueIndex, CallbackInfo ci) {
        this.vivecraft$queueIndex = queueIndex;
    }
}
