# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="A Tokio aware, HTTP/2.0 client & server implementation for Rust."
HOMEPAGE="https://github.com/hyperium/h2"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/byteorder-1.0:=
	>=dev-rust/bytes-0.4.7:=
	>=dev-rust/fnv-1.0.5:=
	>=dev-rust/futures-0.1:=
	>=dev-rust/http-0.1.8:=
	>=dev-rust/indexmap-1.0:=
	>=dev-rust/log-0.4.1:=
	>=dev-rust/slab-0.4.0:=
	>=dev-rust/string-0.2:=
	>=dev-rust/tokio-io-0.1.4:=
"
