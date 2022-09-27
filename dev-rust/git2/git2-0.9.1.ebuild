# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="libgit2 bindings for Rust"
HOMEPAGE="https://github.com/rust-lang/git2-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND=">=dev-rust/bitflags-1.0:=
	>=dev-rust/libc-0.2:=
	>=dev-rust/libgit2-sys-0.8.0:=
	=dev-rust/log-0.4*:=
	=dev-rust/url-1*:=
	>=dev-rust/openssl-probe-0.1.2:=
	>=dev-rust/openssl-sys-0.9.47:=
"

# error: could not compile `git2`
RESTRICT="test"
