# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Rustyline, a readline implementation based on Antirez's Linenoise."
HOMEPAGE="https://docs.rs/rustyline"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

PATCHES=(
	"${FILESDIR}/${PN}-${PV}-rm-optional-features.patch"
	"${FILESDIR}/${PN}-${PV}-upstream-fix-ctrl-right-binding.patch"
)

DEPEND="
	>=dev-rust/bitflags-1.2.0:= <dev-rust/bitflags-2.0.0
	=dev-rust/fs2-0.4*:=
	=dev-rust/libc-0.2*:=
	=dev-rust/log-0.4*:=
	=dev-rust/memchr-2*:=
	=dev-rust/nix-0.19*:=
	=dev-rust/unicode-segmentation-1*:=
	=dev-rust/unicode-width-0.1*:=
	=dev-rust/utf8parse-0.2*:=
"

# error: could not compile `rustyline`
RESTRICT="test"
