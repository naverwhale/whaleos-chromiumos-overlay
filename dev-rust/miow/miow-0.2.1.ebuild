# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A zero overhead Windows I/O library focusing on IOCP and other async I/O features"
HOMEPAGE="https://github.com/alexcrichton/miow"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/kernel32-sys-0.2*:=
	=dev-rust/net2-0.2*:=
	=dev-rust/winapi-0.2*:=
	=dev-rust/ws2_32-sys-0.2*:=
	=dev-rust/rand-0.3*:=
"
