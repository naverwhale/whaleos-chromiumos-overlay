# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Synchronization utilities"
HOMEPAGE="https://tokio.rs/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/fnv-1*:=
	=dev-rust/futures-0.1*:=
	=dev-rust/env_logger-0.5*:=
	=dev-rust/loom-0.1*:=
	=dev-rust/tokio-mock-task-0.1*:=
"

PATCHES=(
	"${FILESDIR}/${P}-0001-Remove-dev-features.patch"
	"${FILESDIR}/${P}-0002-Remove-dev-dependencies.patch"
)
