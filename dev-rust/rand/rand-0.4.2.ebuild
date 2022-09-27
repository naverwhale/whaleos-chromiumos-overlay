# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A Rust library for random number generation."
HOMEPAGE="https://github.com/rust-random/rand"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND=">=dev-rust/fuchsia-zircon-0.3.2:=
	>=dev-rust/winapi-0.3.0:=
	>=dev-rust/libc-0.2.0:=
"
RDEPEND="${DEPEND}"
