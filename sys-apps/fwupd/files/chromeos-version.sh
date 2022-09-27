#!/bin/bash
#
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# This script is given one argument: the base of the source directory of
# the package, and it prints a string on stdout with the numerical version
# number for said repo.

cd "$1" || exit
if [[ -f contrib/get-version.py ]]; then
  contrib/get-version.py | awk -F- '{print $1}'
else
  awk -F"[ ',]+" '/version :/{print $4; exit}' meson.build
fi
