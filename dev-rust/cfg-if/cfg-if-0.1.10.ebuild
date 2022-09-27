# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A macro to ergonomically define an item depending on a large number of #[cfg] parameters"
HOMEPAGE="https://github.com/alexcrichton/cfg-if"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

# error: no matching package named `compiler_builtins` found
RESTRICT="test"
