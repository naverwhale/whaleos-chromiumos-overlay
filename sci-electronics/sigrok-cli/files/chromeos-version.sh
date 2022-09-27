#!/bin/sh
# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

exec gawk '
match($0, /AC_INIT\(\[sigrok-cli\], \[([0-9.]+)\],/, res) { version = res[1] }
END { print version }' "$1/configure.ac"
