# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_RUST_EMPTY_CRATE=1
CROS_RUST_EMPTY_CRATE_FEATURES=(embed_all)

inherit cros-rust

DESCRIPTION="Empty hyphenation crate"
HOMEPAGE=""

LICENSE="BSD-Google"
SLOT="${PV}/${PR}"
KEYWORDS="*"
