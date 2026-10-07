# SPDX-License-Identifier: Apache-2.0

# KernelSU-Next LKM, loaded from the vendor ramdisk
PRODUCT_PACKAGES += \
    kernelsu_init \
    kernelsu_ko

# Set together with the packages above: without /init.ksu in the ramdisk the
# kernel cannot start init and panics.
BOARD_KERNEL_CMDLINE += rdinit=/init.ksu
