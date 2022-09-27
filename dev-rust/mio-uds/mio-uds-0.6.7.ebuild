# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A library for integrating Unix Domain Sockets with mio"
HOMEPAGE="https://github.com/alexcrichton/mio-uds"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/iovec-0.1*:=
	=dev-rust/libc-0.2*:=
	=dev-rust/mio-0.6*:=
	=dev-rust/tempdir-0.3*:=
"
