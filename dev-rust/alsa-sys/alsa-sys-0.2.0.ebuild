# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cros-rust

DESCRIPTION="FFI bindings for the ALSA project (Advanced Linux Sound Architecture)"
HOMEPAGE="https://docs.rs/alsa-sys"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/libc-0.2.65:=
	<dev-rust/libc-0.3
	>=dev-rust/pkg-config-0.3.0:= <dev-rust/pkg-config-0.4.0
	>=media-libs/alsa-lib-1.1.8-r3:= <media-libs/alsa-lib-2.0.0
"
