# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

CROS_RUST_REMOVE_DEV_DEPS=1
CROS_RUST_REMOVE_TARGET_CFG=1

DESCRIPTION="Mio is a lightweight I/O library for Rust with a focus on adding as little overhead as possible over the OS abstractions"
HOMEPAGE="https://github.com/carllerche/mio"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/iovec-0.1.1:= <dev-rust/iovec-0.2
	>=dev-rust/libc-0.2.42:= <dev-rust/libc-0.3.0
	=dev-rust/log-0.4*:=
	>=dev-rust/net2-0.2.29:= <dev-rust/net2-0.3.0
	=dev-rust/slab-0.4*:=
"
RDEPEND="${DEPEND}
	!=dev-rust/mio-0.6*
"
