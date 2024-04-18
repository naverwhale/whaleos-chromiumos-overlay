# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk dlcservice .gn"

PLATFORM_SUBDIR="dlcservice/metadata"

inherit cros-workon platform

DESCRIPTION="DLC metadata library for ChromiumOS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/dlcservice/metadata"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"

# File libdlcservice-metadata.so moved from dlcservice.
RDEPEND="
	!<=chromeos-base/dlcservice-0.0.1-r1073
"

DEPEND="
	${RDEPEND}
"

platform_pkg_test() {
	platform test_all
}
