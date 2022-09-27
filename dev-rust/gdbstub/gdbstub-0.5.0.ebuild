# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="An ergonomic and easy-to-integrate implementation of the GDB Remote Serial Protocol in Rust, with full #![no_std] support."
HOMEPAGE="https://github.com/daniel5151/gdbstub"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/cfg-if-0.1.10:= <dev-rust/cfg-if-0.2
	=dev-rust/log-0.4*:=
	=dev-rust/managed-0.8*:=
	=dev-rust/num-traits-0.2*:=
	=dev-rust/paste-1*:=
"
