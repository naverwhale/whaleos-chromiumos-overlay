# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Parser for rust source code"
HOMEPAGE="https://github.com/dtolnay/syn"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/proc-macro2-0.4.4:=
	=dev-rust/quote-0.6*:=
	=dev-rust/rayon-1.0*:=
	=dev-rust/unicode-xid-0.1*:=
	>=dev-rust/walkdir-2.1.0:=
	=dev-rust/regex-1.0*:=
"
