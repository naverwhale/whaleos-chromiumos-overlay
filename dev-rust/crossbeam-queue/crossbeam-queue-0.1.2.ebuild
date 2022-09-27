# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="This crate provides concurrent queues that can be shared among threads"
HOMEPAGE="https://github.com/crossbeam-rs/crossbeam/tree/master/crossbeam-utils"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/crossbeam-utils-0.6*:=
	=dev-rust/rand-0.6*:=
"
