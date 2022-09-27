# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Native bindings to the libsqlite3 library"
HOMEPAGE="https://github.com/jgallagher/rusqlite"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/bindgen-0.49*:=
	=dev-rust/cc-1*:=
	=dev-rust/pkg-config-0.3*:=
	=dev-rust/vcpkg-0.2*:=
"
