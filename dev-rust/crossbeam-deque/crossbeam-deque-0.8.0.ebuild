# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="This crate provides work-stealing deques, which are primarily intended for building task schedulers"
HOMEPAGE="https://github.com/crossbeam-rs/crossbeam/tree/master/crossbeam-deque"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/cfg-if-1*:=
	=dev-rust/crossbeam-epoch-0.9*:=
	=dev-rust/crossbeam-utils-0.8*:=
"

# error: could not compile `crossbeam-deque`
RESTRICT="test"
