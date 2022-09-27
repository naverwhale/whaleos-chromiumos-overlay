# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="An implementation of regular expressions for Rust. This implementation uses
finite automata and guarantees linear time matching on all inputs."
HOMEPAGE="https://github.com/rust-lang/regex"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/aho-corasick-0.7.18:= <dev-rust/aho-corasick-0.8.0
	>=dev-rust/memchr-2.4.0:= <dev-rust/memchr-3.0.0
	>=dev-rust/regex-syntax-0.6.25:= <dev-rust/regex-syntax-0.7.0
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py

# error: could not compile `regex`
RESTRICT="test"