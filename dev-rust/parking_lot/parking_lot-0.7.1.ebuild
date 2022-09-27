# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="This library provides implementations of Mutex, RwLock, Condvar and Once that are smaller, faster and more flexible than those in the Rust standard library"
HOMEPAGE="https://github.com/Amanieu/parking_lot"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/lock_api-0.1*:=
	=dev-rust/parking_lot_core-0.4*:=
	=dev-rust/rand-0.6*:=
"
