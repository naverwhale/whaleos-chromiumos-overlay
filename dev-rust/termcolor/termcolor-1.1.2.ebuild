# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1
CROS_RUST_REMOVE_TARGET_CFG=1

inherit cros-rust

DESCRIPTION="A simple cross platform library for writing colored text to a terminal."
HOMEPAGE="https://github.com/BurntSushi/termcolor"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"


# This file was automatically generated by cargo2ebuild.py
