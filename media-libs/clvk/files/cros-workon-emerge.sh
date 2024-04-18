#!/bin/bash

# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -xe

[ $# -eq 1 ]

BOARD=$1

SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
THIRD_PARTY_DIR="${SCRIPT_DIR}/../../../.."
BUILD_DIR="/build/${BOARD}/tmp/portage/media-libs/clvk-9999"

if [[ ! -d ${BUILD_DIR} ]]; then
  mkdir -p "${BUILD_DIR}"
  touch "${BUILD_DIR}/.compiled"
  FEATURES="keepwork noclean" emerge-"${BOARD}" clvk || :
fi

rsync --exclude=external/ --exclude=.git -cvr "${THIRD_PARTY_DIR}/clvk/" "${BUILD_DIR}/work/clvk-9999/clvk/"
rsync --exclude=third_party/ --exclude=.git -cvr "${THIRD_PARTY_DIR}/clspv/" "${BUILD_DIR}/work/clvk-9999/clspv/"
rm -f "${BUILD_DIR}/.compiled"
FEATURES="keepwork noclean" emerge-"${BOARD}" clvk
