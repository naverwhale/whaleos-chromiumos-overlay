# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="Get the number of CPUs on a machine"
HOMEPAGE="https://github.com/seanmonstar/num_cpus"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	>=dev-rust/hermit-abi-0.1.3:= <dev-rust/hermit-abi-0.2.0
	>=dev-rust/libc-0.2.26:= <dev-rust/libc-0.3.0
"
