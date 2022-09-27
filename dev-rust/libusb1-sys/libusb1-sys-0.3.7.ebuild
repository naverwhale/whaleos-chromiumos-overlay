# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="FFI bindings for libusb"
HOMEPAGE="https://docs.rs/crate/libusb1-sys/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

PATCHES=(
	"${FILESDIR}/${P}-0001-remove-build-dependencies.patch"
)

DEPEND="
	=dev-rust/libc-0.2*:=
	=dev-rust/pkg-config-0.3*:=
"
# (crbug.com/1182669): build-time only deps need to be in RDEPEND so they are pulled in when
# installing binpkgs since the full source tree is required to use the crate.
RDEPEND="${DEPEND}"
