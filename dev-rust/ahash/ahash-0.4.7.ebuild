# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="A non-cryptographic hash function using AES-NI for high performance"
HOMEPAGE="https://crates.io/crates/ahash"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/const-random-0.1.6:= <dev-rust/const-random-0.2.0
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py

# error: could not compile `ahash`
RESTRICT="test"
