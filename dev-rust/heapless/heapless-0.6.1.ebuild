# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION='"static" friendly data structures that don"t require dynamic memory allocation'
HOMEPAGE='https://crates.io/crates/heapless'
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/as-slice-0.1.5:= <dev-rust/as-slice-0.2.0
	>=dev-rust/generic-array-0.14.4:= <dev-rust/generic-array-0.15.0
	=dev-rust/hash32-0.1*:=
	=dev-rust/stable_deref_trait-1*:=
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py

RESTRICT="test"
