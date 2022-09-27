# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_EMPTY_CRATE=1

inherit cros-rust

DESCRIPTION="Empty crate"
HOMEPAGE=""

LICENSE="BSD-Google"
SLOT="${PV}/${PR}"
KEYWORDS="*"

# This crate breaks the circular dependency
# tokio-io -> futures -> futures-util -> tokio-io
