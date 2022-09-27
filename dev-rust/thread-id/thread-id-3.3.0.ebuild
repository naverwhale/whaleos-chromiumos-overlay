# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Get a unique ID for the current thread in Rust"
HOMEPAGE="https://github.com/ruuda/thread-id"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/libc-0.2*:=
	=dev-rust/redox_syscall-0.1*:=
	=dev-rust/winapi-0.3*:=
"
