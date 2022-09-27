# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Rusqlite is an ergonomic wrapper for using SQLite from Rust"
HOMEPAGE="https://github.com/jgallagher/rusqlite"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/bitflags-1*:=
	=dev-rust/fallible-iterator-0.2*:=
	=dev-rust/fallible-streaming-iterator-0.1*:=
	=dev-rust/libsqlite3-sys-0.15*:=
	=dev-rust/lru-cache-0.1*:=
	=dev-rust/memchr-2.2*:=
	=dev-rust/time-0.1*:=
	=dev-rust/byteorder-1.2*:=
	=dev-rust/chrono-0.4*:=
	=dev-rust/csv-1*:=
	=dev-rust/lazy_static-1*:=
	=dev-rust/serde_json-1*:=
	=dev-rust/url-1.7*:=
	=dev-rust/uuid-0.7*:=
	=dev-rust/regex-1*:=
	=dev-rust/tempdir-0.3*:=
	=dev-rust/unicase-2.4*:=
	=dev-rust/uuid-0.7*:=
"
