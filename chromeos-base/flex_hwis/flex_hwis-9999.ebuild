# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_SUBTREE="common-mk flex_hwis .gn metrics"

PLATFORM_SUBDIR="flex_hwis"

inherit cros-workon platform

DESCRIPTION="Utility to collect/send Hardware Information for ChromeOS Flex"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/flex_hwis"

LICENSE="BSD-Google"
KEYWORDS="~*"
IUSE="flex_internal"

COMMON_DEPEND="
	chromeos-base/diagnostics:=
	chromeos-base/metrics:=
	chromeos-base/mojo_service_manager:=
	dev-libs/protobuf:=
	sys-apps/rootdev:=
"

RDEPEND="
	${COMMON_DEPEND}
	acct-group/flex_hwis
	acct-user/flex_hwis
"

DEPEND="
	${COMMON_DEPEND}
	flex_internal? ( chromeos-base/flex-hwis-private:= )
"

platform_pkg_test() {
	platform test_all
}
