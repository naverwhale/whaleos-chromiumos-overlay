# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Pure Rust implementation of Ryū, an algorithm to quickly convert floating point numbers to decimal strings."
HOMEPAGE="https://github.com/dtolnay/ryu"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( Apache-2.0 Boost-1.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/no-panic-0.1*:=
	>=dev-rust/num_cpus-1.8.0:=
	=dev-rust/rand-0.5*:=
"
