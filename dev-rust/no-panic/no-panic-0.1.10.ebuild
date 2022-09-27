# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A Rust attribute macro to require that the compiler prove a function can't ever panic."
HOMEPAGE="https://github.com/dtolnay/no-panic"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/proc-macro2-0.4*:=
	=dev-rust/quote-0.6*:=
	=dev-rust/syn-0.15*:=
	=dev-rust/tempfile-3*:=
"

# could not compile
RESTRICT="test"
