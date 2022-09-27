# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Event loop that drives Tokio I/O resources"
HOMEPAGE="https://tokio.rs/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/crossbeam-utils-0.6*:=
	=dev-rust/futures-0.1*:=
	=dev-rust/lazy_static-1*:=
	=dev-rust/log-0.4*:=
	=dev-rust/mio-0.6*:=
	=dev-rust/num_cpus-1*:=
	=dev-rust/parking_lot-0.7*:=
	=dev-rust/slab-0.4*:=
	=dev-rust/tokio-executor-0.1*:=
	=dev-rust/tokio-io-0.1*:=
	=dev-rust/tokio-sync-0.1*:=
	=dev-rust/tokio-io-pool-0.1*:=
"

PATCHES=(
	"${FILESDIR}/${P}-0001-Remove-dev-dependencies.patch"
)
