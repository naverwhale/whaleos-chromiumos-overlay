# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1
CROS_RUST_REMOVE_TARGET_CFG=1

inherit cros-rust

DESCRIPTION="A safer binding to platform’s dynamic library loading utilities"
HOMEPAGE="https://crates.io/crates/libloading"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="ISC"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/cfg-if-1*:=
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py