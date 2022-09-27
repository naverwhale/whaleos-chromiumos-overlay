# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION='Minimal runtime / startup for Cortex-M microcontrollers'
HOMEPAGE='https://crates.io/crates/cortex-m-rt'
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	~dev-rust/cortex-m-rt-macros-0.1.8:=
	>=dev-rust/r0-0.2.2:= <dev-rust/r0-0.3.0
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py

src_install() {
	cros-rust_src_install

	# Do not strip prebuilt .a files in the crate sources
	# shellcheck disable=SC2154
	dostrip -x "${CROS_RUST_REGISTRY_BASE}"
}

RESTRICT="test"
