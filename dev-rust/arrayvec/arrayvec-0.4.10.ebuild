# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A vector with fixed capacity, backed by an array (it can be stored on the stack too)"
HOMEPAGE="https://github.com/bluss/arrayvec"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/nodrop-0.1*:=
	=dev-rust/serde-1*:=
	=dev-rust/bencher-0.1*:=
	=dev-rust/matches-0.1*:=
	=dev-rust/serde_test-1*:=
"
