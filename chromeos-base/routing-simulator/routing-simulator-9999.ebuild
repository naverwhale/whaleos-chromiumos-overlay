# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk net-base routing-simulator .gn"

PLATFORM_SUBDIR="routing-simulator"
# Do not run test in parallel to make the unit test failures more obvious.
# shellcheck disable=SC2034
PLATFORM_PARALLEL_GTEST_TEST="no"

inherit cros-workon libchrome platform

DESCRIPTION="Debugging tool for the routing subsystem"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/routing-simulator/"
LICENSE="BSD-Google"
KEYWORDS="~*"
IUSE=""

COMMON_DEPEND="
	chromeos-base/net-base:=
"

RDEPEND="
	${COMMON_DEPEND}
"

DEPEND="
	${COMMON_DEPEND}
"

platform_pkg_test() {
	platform test_all
}
