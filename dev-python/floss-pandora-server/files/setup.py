# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Setup script for the Floss Pandora server."""

import setuptools


setuptools.setup(
    name="floss-pandora-server",
    packages=["floss.pandora.floss", "floss.pandora.server"],
    description="Pandora gRPC sever for Floss Bluetooth stack",
)
