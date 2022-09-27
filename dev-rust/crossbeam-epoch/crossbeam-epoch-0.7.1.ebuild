# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="This crate provides epoch-based garbage collection for building concurrent data structures"
HOMEPAGE="https://github.com/crossbeam-rs/crossbeam/tree/master/crossbeam-epoch"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/arrayvec-0.4*:=
	=dev-rust/cfg-if-0.1*:=
	=dev-rust/crossbeam-utils-0.6*:=
	=dev-rust/memoffset-0.2*:=
	=dev-rust/scopeguard-0.3*:=
	=dev-rust/lazy_static-1*:=
	=dev-rust/rand-0.6*:=
"
