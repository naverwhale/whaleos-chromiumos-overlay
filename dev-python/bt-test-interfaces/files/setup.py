# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Setup script for the bt-test-interfaces."""

import setuptools


setuptools.setup(
    name="bt-test-interfaces",
    packages=["pandora", "pandora_experimental"],
    package_dir={"": "./python"},
    description="AOSP bluetooth test interfaces",
)
