# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION='A substitute implementation of the compiler"s "proc_macro" API to decouple
token-based libraries from the procedural macro use case.'
HOMEPAGE='https://crates.io/crates/proc-macro2'
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/unicode-xid-0.2*:=
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py
