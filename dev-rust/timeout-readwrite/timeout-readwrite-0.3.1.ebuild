# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="A Rust crate providing Reader and Writer structs that timeout"
HOMEPAGE="https://github.com/jcreekmore/timeout-readwrite-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

PATCHES=( "${FILESDIR}/${PN}-${PV}-nix-dependency.patch" )

DEPEND="
	>=dev-rust/lazy_static-1.3.0:= <dev-rust/lazy_static-2.0.0
	>=dev-rust/nix-0.17.0:= <dev-rust/nix-0.20.0
"
