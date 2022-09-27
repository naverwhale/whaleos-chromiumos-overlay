# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Native bindings to the libgit2 library"
HOMEPAGE="https://github.com/rust-lang/git2-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND=">=dev-rust/cc-1.0.25:=
	>=dev-rust/libc-0.2:=
	>=dev-rust/libssh2-sys-0.2.11:=
	>=dev-rust/libz-sys-1.0.22:=
	>=dev-rust/pkg-config-0.3.7:=
	>=dev-rust/openssl-sys-0.9.47:=
"
