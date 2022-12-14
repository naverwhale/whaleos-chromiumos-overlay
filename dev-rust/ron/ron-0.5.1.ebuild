# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION='Rusty Object Notation'
HOMEPAGE='https://github.com/ron-rs/ron'
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/base64-0.10*:=
	=dev-rust/bitflags-1*:=
	=dev-rust/serde-1*:=
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py

IUSE="test"
TEST_DEPS="
	test? (
		=dev-rust/serde_bytes-0.10*:=
		=dev-rust/serde_json-1*:=
	)
"
DEPEND+="${TEST_DEPS}"
RDEPEND+="${TEST_DEPS}"

src_prepare() {
	if use test; then
		CROS_RUST_REMOVE_DEV_DEPS=0
	fi
	cros-rust_src_prepare
}
