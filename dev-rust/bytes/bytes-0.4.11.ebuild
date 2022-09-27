# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A utility library for working with bytes."
HOMEPAGE="https://github.com/tokio-rs/bytes"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/byteorder-1.1*:=
	>=dev-rust/either-1.5.0:=
	>=dev-rust/iovec-0.1.0:=
	>=dev-rust/serde-1.0.0:=
	>=dev-rust/serde_test-1.0.0:=
"
