# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION='Random number generators and other randomness functionality.'
HOMEPAGE='https://rust-random.github.io/book'
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/log-0.4.4:= <dev-rust/log-0.5.0_alpha
	=dev-rust/rand_core-0.6*:=
	>=dev-rust/serde-1.0.103:= <dev-rust/serde-2.0.0_alpha
	=dev-rust/rand_chacha-0.3*:=
	=dev-rust/rand_hc-0.3*:=
	>=dev-rust/libc-0.2.22:= <dev-rust/libc-0.3.0_alpha
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py

# error: no matching package named `packed_simd_2` found
RESTRICT="test"
