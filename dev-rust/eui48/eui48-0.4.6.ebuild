# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="A Rust library to represent and parse IEEE EUI-48 also known as MAC-48 media access control addresses."
HOMEPAGE="https://github.com/abaumhauer/eui48"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/rustc-serialize-0.3.24:= <dev-rust/rustc-serialize-0.4.0
	>=dev-rust/serde-1.0.80:= <dev-rust/serde-2.0.0
	>=dev-rust/serde_json-1.0.37:= <dev-rust/serde_json-2.0.0
"
RDEPEND="${DEPEND}"
