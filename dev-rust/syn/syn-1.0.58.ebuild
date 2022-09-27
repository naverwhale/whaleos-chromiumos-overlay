# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Parser for rust source code"
HOMEPAGE="https://github.com/dtolnay/syn"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/proc-macro2-1.0.13:= <dev-rust/proc-macro2-2
	=dev-rust/quote-1*:=
	=dev-rust/unicode-xid-0.2*:=
"

src_prepare() {
	cros-rust_src_prepare

	# Delete the test dependency, syn-test-suite.
	sed -i '/^test = \[/d' "${S}/Cargo.toml"
}
