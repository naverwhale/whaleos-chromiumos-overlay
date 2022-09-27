# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A common library for linking nghttp2 to rust programs (also known as libnghttp2)."
HOMEPAGE="https://github.com/alexcrichton/nghttp2-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/cc-1.0.24:=
	=dev-rust/libc-0.2*:=
"
