# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cros-rust

DESCRIPTION="DNS protocol library and implementation for Trust-DNS"
HOMEPAGE="http://www.trust-dns.org/index.html"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/byteorder-1*:=
	=dev-rust/data-encoding-2*:=
	=dev-rust/enum-as-inner-0.2*:=
	=dev-rust/failure-0.1*:=
	=dev-rust/futures-0.1*:=
	=dev-rust/idna-0.1*:=
	=dev-rust/lazy_static-1*:=
	=dev-rust/log-0.4*:=
	=dev-rust/openssl-0.10*:=
	=dev-rust/rand-0.6*:=
	=dev-rust/smallvec-0.6*:=
	=dev-rust/socket2-0.3*:=
	=dev-rust/tokio-executor-0.1*:=
	=dev-rust/tokio-io-0.1*:=
	=dev-rust/tokio-reactor-0.1*:=
	=dev-rust/tokio-tcp-0.1*:=
	=dev-rust/tokio-timer-0.2*:=
	=dev-rust/tokio-udp-0.1*:=
	=dev-rust/url-1*:=
	=dev-rust/ring-0.14*:=
	=dev-rust/serde-1*:=
	=dev-rust/untrusted-0.6*:=
	=dev-rust/env_logger-0.6*:=
	=dev-rust/tokio-0.1*:=
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/${P}-0001-Remove-optional-features.patch"
	"${FILESDIR}/${P}-0002-Support-Pointer-Label-Compression.patch"
)
