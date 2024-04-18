# Copyright 2023 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
CROS_WORKON_COMMIT="4d192aa58ccc981e86c38f04c84d2ca414e892ed"
CROS_WORKON_TREE="959c1e97be6bae86cb10faba3c2f864a7b3f842b"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="../platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_SUBTREE="metrics"
CROS_RUST_SUBDIR="metrics/rust-client"

inherit cros-workon cros-rust

DESCRIPTION="Chrome OS metrics rust binding"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/metrics/"
LICENSE="BSD-Google"
KEYWORDS="*"

RDEPEND="chromeos-base/metrics:="
DEPEND="
	${RDEPEND}
	dev-rust/third-party-crates-src:=
"
