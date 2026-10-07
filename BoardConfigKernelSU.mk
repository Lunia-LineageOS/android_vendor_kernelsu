# SPDX-License-Identifier: Apache-2.0

# Without /init.ksu in the ramdisk the kernel cannot start init and panics,
# so only point rdinit at it when the product actually ships it.
ifneq ($(filter kernelsu_init,$(PRODUCT_PACKAGES)),)
BOARD_KERNEL_CMDLINE += rdinit=/init.ksu
endif
