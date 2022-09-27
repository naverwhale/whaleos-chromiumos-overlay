# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A library to compile C/C++/assembly into a Rust library/application"
HOMEPAGE="https://github.com/alexcrichton/cc-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/rayon-1.0.2:=
	>=dev-rust/tempdir-0.3.7:=
"

# could not compile
RESTRICT="test"
