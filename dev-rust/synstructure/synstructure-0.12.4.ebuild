# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="This crate provides helper types for matching against enum variants, and extracting bindings to each of the fields in the deriving Struct or Enum in a generic way"
HOMEPAGE="https://crates.io/crates/synstructure"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/proc-macro2-1*:=
	=dev-rust/quote-1*:=
	=dev-rust/syn-1*:=
	=dev-rust/unicode-xid-0.2*:=
"
RDEPEND="${DEPEND}"
