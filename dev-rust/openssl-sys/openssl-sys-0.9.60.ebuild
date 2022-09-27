# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="OpenSSL bindings for the Rust programming language."
HOMEPAGE="https://github.com/sfackler/rust-openssl"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/autocfg-1*:=
	=dev-rust/cc-1*:=
	=dev-rust/libc-0.2*:=
	>=dev-rust/pkg-config-0.3.9:= <dev-rust/pkg-config-0.4
	>=dev-rust/vcpkg-0.2.8:= <dev-rust/vcpkg-0.3
	>=dev-rust/openssl-src-111.0.1:= <dev-rust/openssl-src-112
"
# (crbug.com/1182669): build-time only deps need to be in RDEPEND so they are
# pulled in when installing binpkgs since the full source tree is required to
# use the crate.
RDEPEND="${DEPEND}
	!=dev-rust/openssl-sys-0.9*
"

PATCHES=( "${FILESDIR}/${P}-include-hdkf.patch" )
