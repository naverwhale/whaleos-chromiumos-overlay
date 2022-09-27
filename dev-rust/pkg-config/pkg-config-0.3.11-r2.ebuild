# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A library to run the pkg-config system tool at build time in order to be used in
Cargo build scripts"
HOMEPAGE="https://github.com/alexcrichton/pkg-config-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/lazy_static-1*:=
"

PATCHES=(
	"${FILESDIR}/${P}-0001-Allow-overriding-system-root.patch"
)
