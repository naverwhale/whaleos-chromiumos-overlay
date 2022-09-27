# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="A bindless library for manipulating terminals."
HOMEPAGE="https://gitlab.redox-os.org/redox-os/termion"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/libc-0.2.8:=
	>=dev-rust/redox_syscall-0.1.0:=
	>=dev-rust/redox_termios-0.1.0:=
"
RDEPEND="${DEPEND}"
