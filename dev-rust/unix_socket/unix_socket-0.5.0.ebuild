# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Support for Unix domain socket clients and servers."
HOMEPAGE="https://github.com/rust-lang-nursery/unix-socket"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND=">=dev-rust/cfg-if-0.1.0:=
	>=dev-rust/libc-0.2.1:=
	>=dev-rust/tempdir-0.3.0:=
"
