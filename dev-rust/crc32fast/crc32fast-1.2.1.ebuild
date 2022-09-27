# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Fast, SIMD-accelerated CRC32 (IEEE) checksum computation"
HOMEPAGE="https://github.com/srijs/rust-crc32fast"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/cfg-if-1:= <dev-rust/cfg-if-2
"

# could not compile
RESTRICT="test"
