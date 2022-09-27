# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="This crate provides miscellaneous tools for concurrent programming"
HOMEPAGE="https://github.com/crossbeam-rs/crossbeam/tree/master/crossbeam-utils"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/autocfg-1*:=
	=dev-rust/cfg-if-1*:=
	=dev-rust/lazy_static-1*:="

# error: no matching package named `loom` found
RESTRICT="test"
