# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Word wrapping text"
HOMEPAGE="https://github.com/mgeisler/textwrap"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

CROS_RUST_REMOVE_DEV_DEPS=1

DEPEND="
	=dev-rust/unicode-width-0.1*:=
	=dev-rust/hyphenation-0.7*:=
	=dev-rust/term_size-0.3*:=
"

# error: could not compile `textwrap`
RESTRICT="test"
