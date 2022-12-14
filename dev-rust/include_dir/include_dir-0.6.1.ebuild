# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION='Embed the contents of a directory in your binary'
HOMEPAGE='https://crates.io/crates/include_dir'
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/glob-0.3*:=
	~dev-rust/include_dir_impl-0.6.1:=
	=dev-rust/proc-macro-hack-0.5*:=
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py

CROS_RUST_REMOVE_DEV_DEPS=0
TEST_DEPS="
	=dev-rust/tempdir-0.3*:=
"
DEPEND+="${TEST_DEPS}"
RDEPEND+="${TEST_DEPS}"
