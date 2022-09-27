# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Unix Domain sockets for Tokio"
HOMEPAGE="https://tokio.rs/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/bytes-0.4*:=
	=dev-rust/futures-0.1*:=
	=dev-rust/iovec-0.1*:=
	=dev-rust/libc-0.2*:=
	=dev-rust/log-0.4*:=
	=dev-rust/mio-0.6*:=
	=dev-rust/mio-uds-0.6*:=
	=dev-rust/tokio-codec-0.1*:=
	=dev-rust/tokio-io-0.1*:=
	=dev-rust/tokio-reactor-0.1*:=
	=dev-rust/tempfile-3*:=
"

PATCHES=(
	"${FILESDIR}/${P}-0001-Remove-dev-dependencies.patch"
)
