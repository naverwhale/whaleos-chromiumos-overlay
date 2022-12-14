# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION='Parser and evaluator for Cargo"s flavor of Semantic Versioning'
HOMEPAGE='https://crates.io/crates/semver'
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/serde-1*:=
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py
