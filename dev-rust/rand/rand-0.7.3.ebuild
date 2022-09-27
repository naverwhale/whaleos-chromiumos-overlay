# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="A Rust library for random number generation."
HOMEPAGE="https://github.com/rust-random/rand"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/getrandom-0.1.1:= <dev-rust/getrandom-0.2.0
	>=dev-rust/libc-0.2.22:= <dev-rust/libc-0.3.0
	>=dev-rust/log-0.4.4:= <dev-rust/log-0.5.0
	>=dev-rust/rand_chacha-0.2.1:= <dev-rust/rand_chacha-0.3.0
	>=dev-rust/rand_core-0.5.1:= <dev-rust/rand_core-0.6.0
	=dev-rust/rand_hc-0.2*:=
	=dev-rust/rand_pcg-0.2*:=
"
RDEPEND="${DEPEND}"

src_prepare() {
	cros-rust_src_prepare

	# Delete the optional packed_simd dependency. This starts a deps chain
	# down to bindgen and beyond.
	sed -i '/\[dependencies.packed_simd\]/{N;N;N;d;}' "${S}/Cargo.toml"
	sed -i '/simd_support/d' "${S}/Cargo.toml"

	# Delete the wasm-only features.
	sed -i '/stdweb = /d' "${S}/Cargo.toml"
	sed -i '/wasm-bindgen = /d' "${S}/Cargo.toml"
}
