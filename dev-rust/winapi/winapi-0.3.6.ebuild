# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="This crate provides raw FFI bindings to all of Windows API."
HOMEPAGE="https://github.com/retep998/winapi-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/winapi-i686-pc-windows-gnu-0.4.0:=
	>=dev-rust/winapi-x86_64-pc-windows-gnu-0.4.0:=
"
