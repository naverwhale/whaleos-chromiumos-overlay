# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="An implementation of an asynchronous HTTP client using futures backed by libcurl."
HOMEPAGE="https://tokio.rs/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/curl-0.4*:=
	=dev-rust/env_logger-0.4*:=
	=dev-rust/futures-0.1*:=
	=dev-rust/libc-0.2*:=
	=dev-rust/log-0.4*:=
	=dev-rust/mio-0.6*:=
	=dev-rust/scoped-tls-0.1*:=
	=dev-rust/slab-0.4*:=
	=dev-rust/tokio-core-0.1*:=
	=dev-rust/tokio-io-0.1*:=
	=dev-rust/winapi-0.3*:=
"
