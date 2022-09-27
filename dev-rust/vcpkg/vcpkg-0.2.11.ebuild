# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="This is a helper for finding native MSVC ABI libraries in a Vcpkg installation from cargo build scripts."
HOMEPAGE="https://github.com/mcgoo/vcpkg-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

RDEPEND="!=dev-rust/vcpkg-0.2*"

# fails to compile
RESTRICT="test"
