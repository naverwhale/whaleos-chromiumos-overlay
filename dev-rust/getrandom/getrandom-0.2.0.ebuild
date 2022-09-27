# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="A Rust library for retrieving random data from (operating) system source"
HOMEPAGE="https://github.com/rust-random/getrandom"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/cfg-if-0.1.2:= <dev-rust/cfg-if-0.2.0
	>=dev-rust/libc-0.2.64:= <dev-rust/libc-0.3.0
	>=dev-rust/wasi-0.9.0:= <dev-rust/wasi-0.10.0
	>=dev-rust/compiler_builtins-0.1.0:= <dev-rust/compiler_builtins-0.2.0
	=dev-rust/rustc-std-workspace-core-1*:=
	>=dev-rust/stdweb-0.4.18:= <dev-rust/stdweb-0.5.0
	>=dev-rust/wasm-bindgen-0.2.62:= <dev-rust/wasm-bindgen-0.3.0
"
