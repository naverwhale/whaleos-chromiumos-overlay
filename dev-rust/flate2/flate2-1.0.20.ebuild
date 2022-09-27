# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="DEFLATE compression and decompression exposed as Read/BufRead/Write streams."
HOMEPAGE="https://github.com/rust-lang/flate2-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/cfg-if-1:= <dev-rust/cfg-if-2
	>=dev-rust/crc32fast-1.2:= <dev-rust/crc32fast-2
	>=dev-rust/libc-0.2.65:= <dev-rust/libc-0.3
	>=dev-rust/miniz_oxide-0.4.0:= <dev-rust/miniz_oxide-0.5
	>=dev-rust/cloudflare-zlib-sys-0.2.0:= <dev-rust/cloudflare-zlib-sys-0.3
	>=dev-rust/futures-0.1.25:= <dev-rust/futures-0.2
	>=dev-rust/libz-sys-1.1.0:= <dev-rust/libz-sys-2
	>=dev-rust/miniz-sys-0.1.11:= <dev-rust/miniz-sys-0.2
	>=dev-rust/tokio-io-0.1.11:= <dev-rust/tokio-io-0.2
"

src_prepare() {
	cros-rust_src_prepare

	# Delete the optional zlib-ng dependency.
	sed -i '/zlib-ng/d' "${S}/Cargo.toml"
}

# could not compile
RESTRICT="test"
