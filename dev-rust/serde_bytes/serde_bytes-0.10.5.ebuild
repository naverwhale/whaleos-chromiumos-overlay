# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Wrapper types to enable optimized handling of &[u8] and Vec<u8>"
HOMEPAGE="https://github.com/serde-rs/bytes"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/bincode-1.0*:=
	=dev-rust/serde-1.0*:=
	=dev-rust/serde_derive-1.0*:=
	=dev-rust/serde_test-1.0*:=
"
