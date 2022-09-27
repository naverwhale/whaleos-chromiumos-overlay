# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Asynchronous filesystem manipulation operations"
HOMEPAGE="https://tokio.rs/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/futures-0.1*:=
	=dev-rust/tokio-io-0.1*:=
	=dev-rust/tokio-threadpool-0.1*:=
	=dev-rust/rand-0.6*:=
	=dev-rust/tempdir-0.3*:=
	=dev-rust/tempfile-3*:=
	=dev-rust/tokio-codec-0.1*:=
"

PATCHES=(
	"${FILESDIR}/${P}-0001-Remove-dev-dependencies.patch"
)
