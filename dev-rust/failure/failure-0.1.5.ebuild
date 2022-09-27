# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Experimental error handling abstraction"
HOMEPAGE="https://rust-lang-nursery.github.io/failure/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/backtrace-0.3*:=
	=dev-rust/failure_derive-0.1*:=
"

PATCHES=(
	"${FILESDIR}/${P}-0001-Remove-makefile.patch"
)
