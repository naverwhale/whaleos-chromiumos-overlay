# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Native bindings to the libssh2 library"
HOMEPAGE="https://github.com/alexcrichton/ssh2-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND=">=dev-rust/cc-1.0.25:=
	>=dev-rust/libc-0.2:=
	>=dev-rust/libz-sys-1.0.21:=
	>=dev-rust/openssl-sys-0.9.35:=
	>=dev-rust/pkg-config-0.3.11:=
	>=dev-rust/vcpkg-0.2:=
"
