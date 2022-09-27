# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="Fast, concurrent hash maps with extensive API"
HOMEPAGE="https://gitlab.redox-os.org/redox-os/chashmap"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/owning_ref-0.3*:=
	=dev-rust/parking_lot-0.4*:=
"
RDEPEND="${DEPEND}"
