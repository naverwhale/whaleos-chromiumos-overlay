# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A trait representing asynchronous operations on an HTTP body."
HOMEPAGE="https://github.com/hyperium/http-body"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/bytes-0.4.11:=
	>=dev-rust/futures-0.1.25:=
	>=dev-rust/http-0.1.16:=
	>=dev-rust/tokio-buf-0.1:=
"
