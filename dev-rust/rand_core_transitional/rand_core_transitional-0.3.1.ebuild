# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

CROS_RUST_CRATE_NAME="rand_core"
DESCRIPTION="Transitional package for ${CROS_RUST_CRATE_NAME}"
HOMEPAGE="https://github.com/rust-random/rand"
SRC_URI="https://crates.io/api/v1/crates/${CROS_RUST_CRATE_NAME}/${PV}/download -> ${CROS_RUST_CRATE_NAME}-${PV}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

S="${WORKDIR}/${CROS_RUST_CRATE_NAME}-${PV}"

DEPEND="
	~dev-rust/rand_core-0.4.0:=
"
