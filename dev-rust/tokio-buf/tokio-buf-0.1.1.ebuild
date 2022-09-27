# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Asynchronous stream of byte buffers"
HOMEPAGE="https://github.com/tokio-rs/tokio"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/bytes-0.4.10:=
	>=dev-rust/futures-0.1.23:=
	>=dev-rust/either-1.5:=
	>=dev-rust/tokio-mock-task-0.1.1:=
"
