# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="Rust bindings to libcurl for making HTTP requests"
HOMEPAGE="https://github.com/alexcrichton/curl-rust"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/curl-sys-0.4.18:= <dev-rust/curl-sys-0.5.0
	>=dev-rust/kernel32-sys-0.2.2:= <dev-rust/kernel32-sys-0.3.0
	>=dev-rust/libc-0.2.42:= <dev-rust/libc-0.3.0
	>=dev-rust/schannel-0.1.13:= <dev-rust/schannel-0.2.0
	>=dev-rust/socket2-0.3.7:= <dev-rust/socket2-0.4.0
	>=dev-rust/winapi-0.2.7:= <dev-rust/winapi-0.3.0
	>=dev-rust/openssl-probe-0.1.2:= <dev-rust/openssl-probe-0.2.0
	>=dev-rust/openssl-sys-0.9.43:= <dev-rust/openssl-sys-0.10.0
	=dev-rust/mio-0.6*:=
	>=dev-rust/mio-extras-2.0.3:= <dev-rust/mio-extras-3.0.0
"
RDEPEND="${DEPEND}"
