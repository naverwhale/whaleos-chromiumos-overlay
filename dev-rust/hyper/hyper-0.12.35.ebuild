# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="A fast and correct HTTP implementation for Rust."
HOMEPAGE="https://github.com/hyperium/hyper"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/bytes-0.4.4:= <dev-rust/bytes-0.5.0
	>=dev-rust/futures-0.1.21:= <dev-rust/futures-0.2.0
	>=dev-rust/h2-0.1.10:= <dev-rust/h2-0.2.0
	>=dev-rust/http-0.1.15:= <dev-rust/http-0.2.0
	=dev-rust/httparse-1*:=
	=dev-rust/http-body-0.1*:=
	=dev-rust/iovec-0.1*:=
	>=dev-rust/itoa-0.4.1:= <dev-rust/itoa-0.5.0
	=dev-rust/log-0.4*:=
	=dev-rust/rustc_version-0.2*:=
	=dev-rust/time-0.1*:=
	=dev-rust/tokio-buf-0.1*:=
	=dev-rust/tokio-io-0.1*:=
	=dev-rust/want-0.2*:=
	>=dev-rust/futures-cpupool-0.1.6:= <dev-rust/futures-cpupool-0.2.0
	>=dev-rust/net2-0.2.32:= <dev-rust/net2-0.3.0
	>=dev-rust/tokio-0.1.14:= <dev-rust/tokio-0.2.0
	=dev-rust/tokio-executor-0.1*:=
	=dev-rust/tokio-reactor-0.1*:=
	=dev-rust/tokio-tcp-0.1*:=
	>=dev-rust/tokio-threadpool-0.1.3:= <dev-rust/tokio-threadpool-0.2.0
	=dev-rust/tokio-timer-0.2*:=
"
RDEPEND="${DEPEND}"
