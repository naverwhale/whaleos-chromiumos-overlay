# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="Native bindings to the libcurl library"
HOMEPAGE="https://github.com/alexcrichton/curl-rust/tree/master/curl-sys"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/cc-1*:=
	>=dev-rust/libc-0.2.2:= <dev-rust/libc-0.3.0
	>=dev-rust/libz-sys-1.0.18:= <dev-rust/libz-sys-2.0.0
	>=dev-rust/pkg-config-0.3.3:= <dev-rust/pkg-config-0.4.0
	=dev-rust/vcpkg-0.2*:=
	=dev-rust/winapi-0.3*:=
	=dev-rust/libnghttp2-sys-0.1*:=
	=dev-rust/openssl-sys-0.9*:=
"
RDEPEND="${DEPEND}"
