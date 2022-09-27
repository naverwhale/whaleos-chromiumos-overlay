# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="Rust bindings to D-Bus."
HOMEPAGE="https://github.com/diwic/dbus-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND=">=dev-rust/libc-0.2.7:=
	>=dev-rust/libdbus-sys-0.1.2:= <dev-rust/libdbus-sys-0.2
	>=dev-rust/tempdir-0.3.0:=
"
RDEPEND="${DEPEND}"
