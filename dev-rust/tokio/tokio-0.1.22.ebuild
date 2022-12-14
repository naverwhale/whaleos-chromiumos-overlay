# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="An event-driven, non-blocking I/O platform for writing asynchronous I/O
backed applications."
HOMEPAGE="https://tokio.rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/bytes-0.4*:=
	>=dev-rust/futures-0.1.20:= <dev-rust/futures-0.2.0
	>=dev-rust/mio-0.6.14:= <dev-rust/mio-0.7.0
	>=dev-rust/num_cpus-1.8.0:= <dev-rust/num_cpus-2.0.0
	=dev-rust/tokio-codec-0.1*:=
	>=dev-rust/tokio-current-thread-0.1.6:= <dev-rust/tokio-current-thread-0.2.0
	>=dev-rust/tokio-executor-0.1.7:= <dev-rust/tokio-executor-0.2.0
	>=dev-rust/tokio-fs-0.1.6:= <dev-rust/tokio-fs-0.2.0
	>=dev-rust/tokio-io-0.1.6:= <dev-rust/tokio-io-0.2.0
	>=dev-rust/tokio-reactor-0.1.1:= <dev-rust/tokio-reactor-0.2.0
	>=dev-rust/tokio-sync-0.1.5:= <dev-rust/tokio-sync-0.2.0
	=dev-rust/tokio-tcp-0.1*:=
	>=dev-rust/tokio-threadpool-0.1.14:= <dev-rust/tokio-threadpool-0.2.0
	>=dev-rust/tokio-timer-0.2.8:= <dev-rust/tokio-timer-0.3.0
	=dev-rust/tokio-udp-0.1*:=
	=dev-rust/tracing-core-0.1*:=
	>=dev-rust/tokio-uds-0.2.1:= <dev-rust/tokio-uds-0.3.0
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py
