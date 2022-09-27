# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION='Transmit defmt log messages over the RTT (Real-Time Transfer) protocol'
HOMEPAGE='https://crates.io/crates/defmt-rtt'
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/cortex-m-0.6.3:= <dev-rust/cortex-m-0.7.0
	=dev-rust/defmt-0.2*:=
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py