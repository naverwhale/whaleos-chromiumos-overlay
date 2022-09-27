# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1
CROS_RUST_REMOVE_TARGET_CFG=1

inherit cros-rust

DESCRIPTION="An advanced API for creating custom synchronization primitives."
HOMEPAGE="https://crates.io/crates/parking_lot_core"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( Apache-2.0 MIT )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/backtrace-0.3.2:= <dev-rust/backtrace-0.4.0
	>=dev-rust/cfg-if-0.1.5:= <dev-rust/cfg-if-0.2.0
	>=dev-rust/petgraph-0.4.5:= <dev-rust/petgraph-0.5.0
	=dev-rust/smallvec-0.6*:=
	>=dev-rust/thread-id-3.2.0:= <dev-rust/thread-id-4.0.0
	=dev-rust/rustc_version-0.2*:=
	>=dev-rust/libc-0.2.55:= <dev-rust/libc-0.3.0
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py