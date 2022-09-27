# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A reliable implementation of remove_dir_all for Windows. For Unix systems re-exports std::fs::remove_dir_all."
HOMEPAGE="https://github.com/Aaronepower/remove_dir_all.git"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND=">=dev-rust/winapi-0.3.0:=
"
