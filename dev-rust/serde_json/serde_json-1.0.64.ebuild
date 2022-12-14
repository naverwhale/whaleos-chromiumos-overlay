# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="A JSON serialization file format"
HOMEPAGE="https://crates.io/crates/serde_json"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/indexmap-1.5.0:= <dev-rust/indexmap-2.0.0
	>=dev-rust/itoa-0.4.3:= <dev-rust/itoa-0.5.0
	=dev-rust/ryu-1*:=
	>=dev-rust/serde-1.0.100:= <dev-rust/serde-2.0.0
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py
