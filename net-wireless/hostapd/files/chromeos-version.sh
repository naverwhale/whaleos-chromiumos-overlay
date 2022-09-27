#!/bin/sh

# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

awk '$2 == "VERSION_STR" {gsub("\"", "", $3); print $3}' "$1"/src/common/version.h
