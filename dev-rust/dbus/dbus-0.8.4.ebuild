# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Rust bindings to D-Bus."
HOMEPAGE="https://github.com/diwic/dbus-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND=">=dev-rust/libc-0.2.66:= <dev-rust/libc-0.3
	=dev-rust/libdbus-sys-0.2*:=
	=dev-rust/futures-0.3*:=
"
RDEPEND="${DEPEND}"

# error: could not compile `dbus`
RESTRICT="test"
