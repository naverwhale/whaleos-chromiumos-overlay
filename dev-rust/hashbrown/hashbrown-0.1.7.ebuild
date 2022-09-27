# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="This crate is a Rust port of Google's high-performance SwissTable hash map, adapted to make it a drop-in replacement for Rust's standard HashMap and HashSet types."
HOMEPAGE="https://github.com/rust-lang/hashbrown"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/byteorder-1.0.0:=
	>=dev-rust/scopeguard-0.3.0:=
	>=dev-rust/serde-1.0.0:=
	>=dev-rust/rand-0.5.1:=
	>=dev-rust/rustc-hash-1.0.0:=
	>=dev-rust/serde_test-1.0.0:=
"
