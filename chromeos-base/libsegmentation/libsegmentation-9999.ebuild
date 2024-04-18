# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk libcrossystem libsegmentation .gn"

PLATFORM_SUBDIR="libsegmentation"

inherit cros-workon platform

DESCRIPTION="Library to get Chromium OS system properties"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/libsegmentation"

LICENSE="BSD-Google"
KEYWORDS="~*"
IUSE="feature_management test"

COMMON_DEPEND="
	chromeos-base/libcrossystem:=[test?]
	dev-libs/protobuf:=
"

RDEPEND="${COMMON_DEPEND}"

DEPEND="${COMMON_DEPEND}
	chromeos-base/feature-management-data:=
"

BDEPEND="
	dev-libs/protobuf
"

platform_pkg_test() {
	platform test_all
}
