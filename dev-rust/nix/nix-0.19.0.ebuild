# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1
CROS_RUST_REMOVE_TARGET_CFG=1

inherit cros-rust

DESCRIPTION="Rust friendly bindings to *nix APIs."
HOMEPAGE="https://github.com/nix-rust/nix"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/bitflags-1.1.0:= <dev-rust/bitflags-2.0.0
	>=dev-rust/cfg-if-0.1.10:= <dev-rust/cfg-if-0.2.0
	>=dev-rust/libc-0.2.78:= <dev-rust/libc-3.0.0
"
RDEPEND="${DEPEND}"

# error: could not compile `nix`
RESTRICT="test"
