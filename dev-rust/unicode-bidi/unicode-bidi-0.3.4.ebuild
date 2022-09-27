# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Implementation of the Unicode Bidirectional Algorithm"
HOMEPAGE="https://github.com/servo/unicode-bidi"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/matches-0.1*:=
	=dev-rust/flame-0.1*:=
	=dev-rust/flamer-0.1*:=
	=dev-rust/serde-1*:=
	=dev-rust/serde_test-1*:=
"
