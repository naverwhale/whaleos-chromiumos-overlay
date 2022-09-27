# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Library for reading/writing numbers in big-endian and little-endian"
HOMEPAGE="https://github.com/BurntSushi/byteorder"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Unlicense )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	~dev-rust/quickcheck-0.4.2:=
	~dev-rust/rand-0.3.20:=
"
