# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A library for acquiring backtraces at runtime for Rust."
HOMEPAGE="https://github.com/alexcrichton/backtrace-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND=">=dev-rust/cfg-if-0.1.0:=
	>=dev-rust/libc-0.2.0:=
	>=dev-rust/addr2line-0.6.0:=
	>=dev-rust/backtrace-sys-0.1.3:=
	>=dev-rust/rustc-demangle-0.1.4:=
	>=dev-rust/cpp_demangle-0.2.3:=
	>=dev-rust/findshlibs-0.3.3:=
	>=dev-rust/gimli-0.15.0:=
	>=dev-rust/memmap-0.6.2:=
	>=dev-rust/object-0.7.0:=
	>=dev-rust/rustc-serialize-0.3.0:=
	>=dev-rust/serde-1.0.0:=
	>=dev-rust/serde_derive-1.0.0:=
	>=dev-rust/winapi-0.3.3:=
"

# error: could not compile `backtrace`
RESTRICT="test"
