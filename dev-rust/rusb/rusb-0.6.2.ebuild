# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Rust library for accessing USB devices"
HOMEPAGE="https://docs.rs/crate/rusb/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/libusb1-sys-0.3.5:= <dev-rust/libusb1-sys-0.4
	=dev-rust/libc-0.2*:=
"
