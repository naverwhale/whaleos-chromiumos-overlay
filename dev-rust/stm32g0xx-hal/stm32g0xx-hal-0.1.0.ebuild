# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION='Peripheral access API for STM32G0 series microcontrollers'
HOMEPAGE='https://crates.io/crates/stm32g0xx-hal'
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/bare-metal-1*:=
	>=dev-rust/cortex-m-0.7.1:= <dev-rust/cortex-m-0.8.0
	>=dev-rust/embedded-hal-0.2.4:= <dev-rust/embedded-hal-0.3.0
	=dev-rust/nb-1*:=
	=dev-rust/stm32g0-0.13*:=
	>=dev-rust/void-1.0.2:= <dev-rust/void-2.0.0
"
RDEPEND="${DEPEND}"

# This file was automatically generated by cargo2ebuild.py

# thread 'main' panicked at 'No device features selected', /build/zork/usr/lib/cros_rust_registry/registry/stm32g0-0.13.0/build.rs:20:18
RESTRICT="test"
