# KernelSU-Next (LKM)

Loads KernelSU-Next as a kernel module on the stock signed GKI, without
touching boot or init_boot:

1. `rdinit=/init.ksu` on the vendor_boot cmdline makes the kernel run
   `/init.ksu` instead of `/init`.
2. `/init.ksu` is upstream `ksuinit` with
   `ksuinit/0001-ksuinit-Support-starting-via-rdinit.patch`. It loads
   `/kernelsu.ko` and then execs the untouched first stage `/init`.

Both files are installed to the vendor ramdisk root. The manager app is not
bundled: install the official KernelSU-Next APK.

| File | Source |
|---|---|
| `prebuilt/kernelsu.ko` | v3.4.0 `aarch64-android14-6.1_kernelsu.ko`, sha256 `0d6f528552f520644c55626ba714a6b0ce2c6e83f501860b3fcd739823bd80c0` |
| `prebuilt/init.ksu` | v3.4.0 (`1a879d6a`) `userspace/ksuinit` + patch, NDK r29, sha256 `5916a2e1272d2ad343184e4300b241fbb77e02423bdc79f1c50989e6920ab6f6` |

Update with `./update.sh <tag> <ndk dir> [kmi]`. The KMI defaults to
`android14-6.1`; pass e.g. `android16-6.12` after a kernel upgrade.

Licenses: `kernelsu.ko` is GPL-2.0-only (`LICENSE.GPL-2.0`), `ksuinit` is
GPL-3.0 (`LICENSE.GPL-3.0`).
