# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="A compact encoder / decoder pair that uses a binary zero-fluff encoding scheme"
HOMEPAGE="https://github.com/TyOverby/bincode"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/byteorder-1.2.0:= <dev-rust/byteorder-2.0.0
	>=dev-rust/serde-1.0.63:= <dev-rust/serde-2.0.0
	>=dev-rust/serde_derive-1.0.27:= <dev-rust/serde_derive-2.0.0
"
