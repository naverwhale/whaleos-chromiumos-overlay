# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="This crate provides helper types for matching against enum variants, and extracting bindings to each of the fields in the deriving Struct or Enum in a generic way"
HOMEPAGE="https://crates.io/crates/synstructure"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/proc-macro2-0.4*:=
	=dev-rust/quote-0.6*:=
	=dev-rust/syn-0.15*:=
	=dev-rust/unicode-xid-0.1*:=
	=dev-rust/synstructure_test_traits-0.1*:=
"
