# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="A simple clean-room implementation of the Adler-32 checksum"
HOMEPAGE="https://github.com/jonas-schievink/adler.git"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )" # FIXME: or BSD-0
SLOT="${PV}/${PR}"
KEYWORDS="*"

# error: no matching package named `compiler_builtins` found
RESTRICT="test"
