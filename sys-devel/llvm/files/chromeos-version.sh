#!/bin/bash -eu
# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This script determines the automatic naming scheme for LLVM-related
# ebuilds. e.g. '17.0_pre511803'. It's invoked by
# portage_util.Ebuild.GetVersion through PUPr or cros_uprev as:
#
# bash -x \
#  <full path to package>/files/chromeos-version.sh \
#  <full path to CROS_WORKON_LOCALNAME value>

set -o pipefail

CUR_FILES_DIR="$(dirname "$(readlink -f "$0")")"
GIT_LLVM_REV="${CUR_FILES_DIR}/patch_manager/git_llvm_rev.py"
HEAD_SHA="$(git -C "$1" rev-parse HEAD)"
LLVM_SVN_REV="$("${GIT_LLVM_REV}"  --llvm_dir "$1" --sha "${HEAD_SHA}" \
    | cut -d 'r' -f 2)"

get_cmake_version() {
  local var="$1"
  local cmakefile="$2"
  grep -oE "set\(\s*${var}\s+[0-9]+\s*\)" "${cmakefile}" \
    | sed -E "s/.*${var}\s+([0-9]+).*/\1/g"
}

LLVM_MAJOR="$(get_cmake_version 'LLVM_VERSION_MAJOR' "$1/llvm/CMakeLists.txt")"
LLVM_MINOR="$(get_cmake_version 'LLVM_VERSION_MINOR' "$1/llvm/CMakeLists.txt")"
echo "${LLVM_MAJOR}.${LLVM_MINOR}_pre${LLVM_SVN_REV}"
