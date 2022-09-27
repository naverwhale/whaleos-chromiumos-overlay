# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A cache that holds a limited number of key-value pairs"
HOMEPAGE="https://github.com/contain-rs/lru-cache"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/linked-hash-map-0.5*:=
	=dev-rust/heapsize-0.4*:=
"
