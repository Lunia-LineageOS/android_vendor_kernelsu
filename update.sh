#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
#
# Update prebuilt/ to a KernelSU-Next release: fetch and verify the
# kernelsu.ko for the given KMI, and rebuild ksuinit with our patch applied.
#
# usage: update.sh <release tag> <android ndk dir> [kmi, default android14-6.1]

set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "usage: $0 <release tag> <android ndk dir> [kmi, default android14-6.1]" >&2
  exit 1
fi

TAG="$1"
NDK="$(realpath "$2")"
KMI="${3:-android14-6.1}"
REPO="KernelSU-Next/KernelSU-Next"
KO="aarch64-${KMI}_kernelsu.ko"
MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

gh release download "${TAG}" -R "${REPO}" -p "${KO}" -D "${WORK}"
expected="$(gh api "repos/${REPO}/releases/tags/${TAG}" \
  --jq ".assets[] | select(.name == \"${KO}\") | .digest")"
actual="sha256:$(sha256sum "${WORK}/${KO}" | cut -d' ' -f1)"
if [[ "${expected}" != "${actual}" ]]; then
  echo "${KO}: digest mismatch (expected ${expected}, got ${actual})" >&2
  exit 1
fi

git clone -q --depth 1 --branch "${TAG}" "https://github.com/${REPO}" "${WORK}/src"
git -C "${WORK}/src" apply "${MY_DIR}"/ksuinit/*.patch

# Same toolchain and flags as upstream's ksuinit workflow
LLVM_BIN="${NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin"
CLANG="${LLVM_BIN}/aarch64-linux-android26-clang"
BUILTINS="$("${CLANG}" --print-resource-dir)/lib/linux/libclang_rt.builtins-aarch64-android.a"
(
  cd "${WORK}/src/userspace/ksuinit"
  CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER="${CLANG}" \
  RUSTFLAGS="-C target-feature=+crt-static -C link-arg=-Wl,-z,max-page-size=16384 -C link-arg=-Wno-unused-command-line-argument -C link-arg=${BUILTINS}" \
    cargo build --target=aarch64-linux-android --release
)

install -m 0644 "${WORK}/${KO}" "${MY_DIR}/prebuilt/kernelsu.ko"
install -m 0644 "${WORK}/src/userspace/ksuinit/target/aarch64-linux-android/release/ksuinit" \
  "${MY_DIR}/prebuilt/init.ksu"

echo "Updated to ${TAG} ($(git -C "${WORK}/src" rev-parse --short HEAD)), KMI ${KMI}:"
(cd "${MY_DIR}" && sha256sum prebuilt/*)
