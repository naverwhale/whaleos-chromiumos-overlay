# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="This crate defines an unsafe marker trait, StableDeref, for container types which deref to a fixed address which is valid even when the containing type is moved."
HOMEPAGE="https://github.com/storyyeller/stable_deref_trait"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"
