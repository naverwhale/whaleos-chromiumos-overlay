# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A hash table with consistent order and fast iteration."
HOMEPAGE="https://github.com/bluss/indexmap"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/serde-1*:=
	=dev-rust/fnv-1*:=
	=dev-rust/itertools-0.7*:=
	=dev-rust/lazy_static-1*:=
	=dev-rust/quickcheck-0.6*:=
	=dev-rust/rand-0.4*:=
	>=dev-rust/serde_test-1.0.5:=
"
