# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="A TOML decoder and encoder for Rust."
HOMEPAGE="https://github.com/alexcrichton/toml-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND=">=dev-rust/serde-1.0:=
	>=dev-rust/linked-hash-map-0.5.2:=
"

# error: could not compile `toml`
RESTRICT="test"
