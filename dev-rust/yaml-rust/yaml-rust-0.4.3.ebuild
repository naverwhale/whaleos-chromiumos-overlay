# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="The missing YAML 1.2 parser for rust"
HOMEPAGE="https://docs.rs/yaml-rust/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"


LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/linked-hash-map-0.0.9:=
	<dev-rust/linked-hash-map-0.6
"

# could not compile
RESTRICT="test"
