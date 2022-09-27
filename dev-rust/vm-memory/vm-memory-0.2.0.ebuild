# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Safe abstractions for accessing the VM physical memory"
HOMEPAGE="https://github.com/rust-vmm/vm-memory"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="Apache-2.0 BSD-Google"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/libc-0.2.39:=
	>=dev-rust/arc-swap-0.4.5:=
"
