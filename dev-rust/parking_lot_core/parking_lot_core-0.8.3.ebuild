# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1
CROS_RUST_REMOVE_TARGET_CFG=1

inherit cros-rust

DESCRIPTION="An advanced API for creating custom synchronization primitives"
HOMEPAGE="https://github.com/Amanieu/parking_lot"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/cfg-if-1*:=
	>=dev-rust/instant-0.1.4:= <dev-rust/instant-2.0.0
	>=dev-rust/libc-0.2.71:= <dev-rust/libc-0.3.0
	>=dev-rust/smallvec-1.6.1 <dev-rust/smallvec-2.0.0
	>=dev-rust/thread-id-3.3.0:= <dev-rust/thread-id-4.0.0
"

RDEPEND="${DEPEND}"
