# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A runtime for writing reliable, asynchronous, and slim applications with the Rust programming language"
HOMEPAGE="https://tokio.rs/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/bytes-0.4*:=
	=dev-rust/futures-0.1*:=
	=dev-rust/mio-0.6*:=
	=dev-rust/num_cpus-1*:=
	=dev-rust/tokio-async-await-0.1*:=
	=dev-rust/tokio-codec-0.1*:=
	=dev-rust/tokio-current-thread-0.1*:=
	=dev-rust/tokio-executor-0.1*:=
	=dev-rust/tokio-fs-0.1*:=
	=dev-rust/tokio-io-0.1*:=
	=dev-rust/tokio-reactor-0.1*:=
	=dev-rust/tokio-sync-0.1*:=
	=dev-rust/tokio-tcp-0.1*:=
	=dev-rust/tokio-threadpool-0.1*:=
	=dev-rust/tokio-timer-0.2*:=
	=dev-rust/tokio-trace-core-0.1*:=
	=dev-rust/tokio-udp-0.1*:=
	=dev-rust/tokio-uds-0.2*:=
	=dev-rust/env_logger-0.5*:=
	=dev-rust/flate2-1*:=
	=dev-rust/futures-cpupool-0.1*:=
	=dev-rust/http-0.1*:=
	=dev-rust/httparse-1*:=
	=dev-rust/libc-0.2*:=
	=dev-rust/serde-1*:=
	=dev-rust/serde_derive-1*:=
	=dev-rust/serde_json-1*:=
	=dev-rust/time-0.1*:=
"

PATCHES=(
	"${FILESDIR}/${P}-0001-Remove-dev-features.patch"
)
