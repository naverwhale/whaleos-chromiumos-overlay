# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Unicode character composition and decomposition utilities"
HOMEPAGE="https://github.com/unicode-rs/unicode-normalization"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/smallvec-0.6*:=
"

# error: could not compile `unicode-normalization`
RESTRICT="test"
