# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="An implementation of regular expressions for Rust."
HOMEPAGE="https://docs.rs/crate/regex/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/aho-corasick-0.6.7:= <dev-rust/aho-corasick-0.7.0
	>=dev-rust/memchr-2.0.2:= <dev-rust/memchr-3.0.0
	>=dev-rust/thread_local-0.3.6:= <dev-rust/thread_local-0.4.0
	>=dev-rust/regex-syntax-0.6.2:= <dev-rust/regex-syntax-0.7.0
	>=dev-rust/utf8-ranges-1.0.1:= <dev-rust/utf8-ranges-1.2.0
"
