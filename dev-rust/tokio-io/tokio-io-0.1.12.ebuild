# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Core I/O primitives for asynchronous I/O in Rust"
HOMEPAGE="https://tokio.rs/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/bytes-0.4*:=
	=dev-rust/futures-0.1*:=
	=dev-rust/log-0.4*:=
	=dev-rust/tokio-current-thread-0.1*:=
"
