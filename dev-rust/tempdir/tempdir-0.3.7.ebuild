# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="A Rust library for creating a temporary directory and deleting its entire contents when the directory is dropped."
HOMEPAGE="https://github.com/rust-lang/tempdir"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/rand-0.4*:=
	=dev-rust/remove_dir_all-0.5*:=
"
RDEPEND="${DEPEND}"
