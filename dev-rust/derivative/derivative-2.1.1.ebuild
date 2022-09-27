# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="A set of alternative 'derive' attributes for Rust."
HOMEPAGE="https://github.com/mcarton/rust-derivative"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/proc-macro2-1*:=
	=dev-rust/quote-1*:=
	>=dev-rust/syn-1.0.3:= <dev-rust/syn-2
"
src_unpack() {
	cros-rust_src_unpack

	# This consists of a recipe "publish_doc" which is unnecessary and requires node js.
	mv "${S}"/Makefile "${S}"/ignore-docs-Makefile
}

RESTRICT="test"
