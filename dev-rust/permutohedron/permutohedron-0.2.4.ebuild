# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION='Generate permutations of sequences. Either lexicographical order permutations, or a minimal swaps permutation sequence implemented using Heap"s algorithm.'
HOMEPAGE='https://crates.io/crates/permutohedron'
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"


# This file was automatically generated by cargo2ebuild.py

RESTRICT="test"
