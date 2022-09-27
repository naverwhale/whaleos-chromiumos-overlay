# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="Parse command line argument by defining a struct, derive crate"
HOMEPAGE="https://github.com/TeXitoi/structopt"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/heck-0.3*:=
	=dev-rust/proc-macro2-1*:=
	=dev-rust/proc-macro-error-1*:=
	=dev-rust/quote-1*:=
	=dev-rust/syn-1*:=
"
