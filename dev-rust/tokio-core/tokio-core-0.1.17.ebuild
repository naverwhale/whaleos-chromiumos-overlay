# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Core I/O and event loop abstraction for asynchronous I/O in Rust built on futures and mio."
HOMEPAGE="https://tokio.rs/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/bytes-0.3*:=
	=dev-rust/futures-0.1*:=
	=dev-rust/futures-cpupool-0.1*:=
	=dev-rust/iovec-0.1*:=
	=dev-rust/log-0.4*:=
	=dev-rust/mio-0.6*:=
	=dev-rust/scoped-tls-0.1*:=
	=dev-rust/tokio-0.1*:=
	=dev-rust/tokio-executor-0.1*:=
	=dev-rust/tokio-io-0.1*:=
	=dev-rust/tokio-reactor-0.1*:=
	=dev-rust/tokio-timer-0.2*:=
	=dev-rust/http-0.1*:=
	=dev-rust/httparse-1.0*:=
"

PATCHES=(
	"${FILESDIR}/${P}-0001-Remove-dev-dependencies.patch"
)
