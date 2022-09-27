# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Serde is a framework for serializing and deserializing Rust data structures efficiently and generically."
HOMEPAGE="https://github.com/serde-rs/json"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/itoa-0.4.3:=
	=dev-rust/ryu-0.2*:=
	>=dev-rust/serde-1.0.60:=
	=dev-rust/indexmap-1*:=
	=dev-rust/automod-0.1*:=
	=dev-rust/compiletest_rs-0.3*:=
	=dev-rust/serde_derive-1*:=
	=dev-rust/serde_stacker-0.1*:=
"
