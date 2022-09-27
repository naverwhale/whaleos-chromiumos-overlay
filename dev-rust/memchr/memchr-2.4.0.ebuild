# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Safe interface to memchr."
HOMEPAGE="https://github.com/BurntSushi/rust-memchr"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/libc-0.2.18:= <dev-rust/libc-0.3.0
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py

# error: could not compile `memchr`
RESTRICT="test"
