# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="Rust bindings to the Windows SChannel APIs providing TLS client and server functionality."
HOMEPAGE="https://github.com/steffengy/schannel-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/lazy_static-1*:=
	=dev-rust/winapi-0.3*:=
"
