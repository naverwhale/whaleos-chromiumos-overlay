# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="Wrappers to create fully-featured Mutex and RwLock types. Compatible with no_std"
HOMEPAGE="https://github.com/Amanieu/parking_lot"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/scopeguard-1.1.0:= <dev-rust/scopeguard-2.0.0
	>=dev-rust/owning_ref-0.4.1:= <dev-rust/owning_ref-0.5.0
"

RDEPEND="${DEPEND}"
