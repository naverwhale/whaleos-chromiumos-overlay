# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="An advanced API for creating custom synchronization primitives"
HOMEPAGE="https://github.com/Amanieu/parking_lot"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/libc-0.2*:=
	=dev-rust/rand-0.6*:=
	=dev-rust/rustc_version-0.2*:=
	=dev-rust/smallvec-0.6*:=
	=dev-rust/winapi-0.3*:=
	=dev-rust/backtrace-0.3*:=
	=dev-rust/petgraph-0.4*:=
	=dev-rust/thread-id-3*:=
"
