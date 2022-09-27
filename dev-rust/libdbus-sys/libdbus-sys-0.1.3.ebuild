# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="Rust FFI bindings to libdbus."
HOMEPAGE="https://github.com/diwic/dbus-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

# Any ebuild that installs binaries and pulls this ebuild into the depgraph
# needs to RDEPEND on sys-apps/dbus.

DEPEND=">=dev-rust/pkg-config-0.3:=
	sys-apps/dbus
"
RDEPEND="${DEPEND}"
