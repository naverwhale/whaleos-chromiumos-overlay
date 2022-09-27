# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="An implementation of random number generator based on rdrand and rdseed instructions"
HOMEPAGE="https://github.com/nagisa/rust_rdrand/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="ISC"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	~dev-rust/rand_core_transitional-0.3.1:=
"
