#!/bin/bash -eu
# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# This script applies `bazel-ignore-gnu-offset-of-extension.patch` to `upb`.
# There's a lot of ceremony around doing so, since `upb` is a dependency of
# grpc, which is a dependency of bazel. Hence:
# - The SHA of upb's tarball is baked into grpc's traball
# - The SHA of grpc's tarball is baked into bazel's sources
#
# So this script handles cleaning all of that up, too. Please note that it
# relies on env vars exported by portage.

set -o pipefail

bazel_checksum() {
  sha256sum "$1" > >(awk '{print $1}')
}

die() {
  echo "$@" >&2
  exit 1
}

# shellcheck disable=SC2154 # PV is set by the ebuild
case "${PV}" in
  5* )
    upb_hash="2de300726a1ba2de9a468468dc5ff9ed17a3215f"
    upb_patch_name="bazel-5-ignore-gnu-offset-of-extension.patch"
    grpc_version="1.41.0"
    ;;
  6* )
    upb_hash="a5477045acaa34586420942098f5fecd3570f577"
    upb_patch_name="bazel-6-ignore-gnu-offset-of-extension.patch"
    grpc_version="1.47.0"
    ;;
  * )
    die "Unknown bazel version; don't know how to patch it"
    ;;
esac

# Unpack, patch, and repack the upb tarball
# shellcheck disable=SC2154 # S is set by the ebuild
distdir="${S}/derived/distdir"
upb_tar="${distdir}/${upb_hash}.tar.gz"
old_upb_checksum="$(bazel_checksum "${upb_tar}")"
# shellcheck disable=SC2154 # T is set by the ebuild
mkdir "${T}/patched-upb"
cd "${T}/patched-upb"
tar xaf "${upb_tar}"
# shellcheck disable=SC2154 # FILESDIR is set by the ebuild
(cd "upb-${upb_hash}" && patch -p1 < "${FILESDIR}/${upb_patch_name}")

rm -f "${upb_tar}"
tar caf "${upb_tar}" .
upb_checksum="$(bazel_checksum "${upb_tar}")"

if [[ "${upb_checksum}" == "${old_upb_checksum}" ]]; then
  die "Somehow the patch didn't apply to ${upb_tar}?"
fi
echo "Successfully patched upb; new checksum: ${upb_checksum}"

# Patch the grpc tarball's upb checksum
grpc_tar="${distdir}/v${grpc_version}.tar.gz"
old_grpc_checksum="$(bazel_checksum "${grpc_tar}")"

mkdir "${T}/patched-grpc"
cd "${T}/patched-grpc"
tar xaf "${grpc_tar}"

sed -i "s|${old_upb_checksum}|${upb_checksum}|g" "grpc-${grpc_version}/bazel/grpc_deps.bzl"
rm -f "${grpc_tar}"
tar caf "${grpc_tar}" .
grpc_checksum="$(bazel_checksum "${grpc_tar}")"

if [[ "${grpc_checksum}" == "${old_grpc_checksum}" ]]; then
  die "Somehow the patch didn't apply to ${grpc_tar}?"
fi
echo "Successfully patched grpc; new checksum: ${grpc_checksum}"

# Finally, update distdir_deps with new checksums.
sed -i \
  -e "s|${old_upb_checksum}|${upb_checksum}|g" \
  -e "s|${old_grpc_checksum}|${grpc_checksum}|g" \
  "${S}/distdir_deps.bzl"
