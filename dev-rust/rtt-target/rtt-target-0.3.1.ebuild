# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION='Target side implementation of the RTT (Real-Time Transfer) I/O protocol'
HOMEPAGE='https://crates.io/crates/rtt-target'
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/cortex-m-0.7.1 <dev-rust/cortex-m-0.8.0_alpha:=
	=dev-rust/riscv-0.6*:=
	=dev-rust/ufmt-write-0.1*:=
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py