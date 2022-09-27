# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION='Framework for writing D-Bus method handlers (legacy)'
HOMEPAGE='https://crates.io/crates/dbus-tree'
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( Apache-2.0 MIT )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/dbus-0.9*:=
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py