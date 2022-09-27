# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Automatically generates Rust FFI bindings to C and C++ libraries."
HOMEPAGE="https://github.com/rust-lang/rust-bindgen"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="BSD"
SLOT="0/${PVR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/bitflags-1.0.3:= <dev-rust/bitflags-2.0.0
	=dev-rust/cexpr-0.4*:=
	=dev-rust/clap-2*:=
	=dev-rust/clang-sys-1*:=
	=dev-rust/env_logger-0.8*:=
	=dev-rust/lazycell-1*:=
	=dev-rust/lazy_static-1*:=
	>=dev-rust/peeking_take_while-0.1.2:= <dev-rust/peeking_take_while-0.2.0
	=dev-rust/quote-1*:=
	=dev-rust/regex-1*:=
	>=dev-rust/rustc-hash-1.0.1:= <dev-rust/rustc-hash-2.0.0
	=dev-rust/shlex-0.1*:=
	=dev-rust/proc-macro2-1*:=
	=dev-rust/which-3*:=
"

src_compile() {
	ecargo_build
}

src_install() {
	dobin "$(cros-rust_get_build_dir)/bindgen"
}
