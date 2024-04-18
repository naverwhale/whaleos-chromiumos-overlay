#!/bin/bash

# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -xe

SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
_CLVK_DIR="${SCRIPT_DIR}/.."
THIRD_PARTY_DIR="${_CLVK_DIR}/../../.."

inherit() {
  return 0
}

export FILESDIR="${_CLVK_DIR}/../clvk-test/files"
# shellcheck source=/dev/null
source "${_CLVK_DIR}/../clvk-test/clvk-test-0.0.1"*

ALL_PATCHES=("${PATCHES[@]}")

export FILESDIR="${_CLVK_DIR}/files"
# shellcheck source=/dev/null
source "${_CLVK_DIR}/clvk-0.0.1"*

CLVK_SHA1=${CROS_WORKON_COMMIT[0]:?}
CLSPV_SHA1=${CROS_WORKON_COMMIT[1]:?}

git -C "${THIRD_PARTY_DIR}/clvk" checkout "${CLVK_SHA1}"
git -C "${THIRD_PARTY_DIR}/clspv" checkout "${CLSPV_SHA1}"

ALL_PATCHES+=("${PATCHES[@]}")

for patch in "${ALL_PATCHES[@]}"; do
  repo=$(basename "${patch}" | sed 's|^\([^-]*\)-.*$|\1|')
  git -C "${THIRD_PARTY_DIR}/${repo}" apply -p2 "${patch}"
  git -C "${THIRD_PARTY_DIR}/${repo}" add --all
  git -C "${THIRD_PARTY_DIR}/${repo}" commit -m "$(basename "${patch}")"
done
