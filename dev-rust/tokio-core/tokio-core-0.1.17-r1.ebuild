# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Core I/O and event loop abstraction for asynchronous I/O in Rust built on futures and mio."
HOMEPAGE="https://tokio.rs/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/bytes-0.4*:=
	=dev-rust/futures-0.1*:=
	=dev-rust/iovec-0.1*:=
	=dev-rust/log-0.4*:=
	>=dev-rust/mio-0.6.12:= <dev-rust/mio-0.7.0
	=dev-rust/scoped-tls-0.1*:=
	>=dev-rust/tokio-0.1.5:= <dev-rust/tokio-0.2.0
	>=dev-rust/tokio-executor-0.1.2:= <dev-rust/tokio-executor-0.2.0
	=dev-rust/tokio-io-0.1*:=
	>=dev-rust/tokio-reactor-0.1.1:= <dev-rust/tokio-reactor-0.2.0
	>=dev-rust/tokio-timer-0.2.1:= <dev-rust/tokio-timer-0.3.0
"
# (crbug.com/1182669): build-time only deps need to be in RDEPEND so they are pulled in when
# installing binpkgs since the full source tree is required to use the crate.
RDEPEND="${DEPEND}"
