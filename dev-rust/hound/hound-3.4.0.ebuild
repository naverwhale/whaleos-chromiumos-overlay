# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1

inherit cros-rust

DESCRIPTION="A wav encoding and decoding library"
HOMEPAGE="https://github.com/ruuda/hound"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND=""
