# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="YAML support for Serde"
HOMEPAGE="https://docs.rs/crate/serde_yaml"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/dtoa-0.4*:=
	=dev-rust/linked-hash-map-0.5*:=
	>=dev-rust/serde-1.0.60:=
	<dev-rust/serde-2.0
	=dev-rust/yaml-rust-0.4*:=
"
