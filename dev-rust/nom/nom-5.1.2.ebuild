# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="A byte-oriented, zero-copy, parser combinators library"
HOMEPAGE="https://github.com/Geal/nom"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/lazy_static-1*:=
	>=dev-rust/lexical-core-0.6.0 <dev-rust/lexical-core-0.8.0
	=dev-rust/memchr-2*:=
	=dev-rust/regex-1*:=
	=dev-rust/version_check-0.9*:=
"

# error: could not compile `nom`
RESTRICT="test"
