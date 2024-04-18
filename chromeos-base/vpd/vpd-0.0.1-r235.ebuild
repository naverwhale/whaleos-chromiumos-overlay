# Copyright 2012 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT=("ae07277fe7394cbb60e746d21d17f2f0a1ac163b" "d6ff7f1016eed50d307c5bb53d3ecbb0d2689c1a")
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6" "726ab5c4f7aea46173d1a595f1e349ca79caf0d7")
CROS_WORKON_PROJECT=("chromiumos/platform2" "chromiumos/platform/vpd")
CROS_WORKON_LOCALNAME=("platform2" "platform/vpd")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/vpd")
CROS_WORKON_SUBTREE=("common-mk .gn" "")

PLATFORM_SUBDIR="vpd"

inherit cros-workon platform systemd

DESCRIPTION="ChromeOS vital product data utilities"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/vpd/"
SRC_URI="gs://chromeos-localmirror/distfiles/${PN}-testdata-0.0.3.tar.xz"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="cros_host systemd test"

# util-linux is for libuuid.
DEPEND="
	sys-apps/flashmap:=
	sys-apps/flashrom:=
	sys-apps/util-linux:=
"

# shflags for dump_vpd_log.
# chromeos-activate-date for ActivateDate upstart and script.
RDEPEND="
	${DEPEND}
	test? ( app-alternatives/tar )
	!cros_host? (
		dev-util/shflags
		virtual/chromeos-activate-date
	)
"

# Unit tests generate FMAP files with fmaptool from coreboot-utils.
BDEPEND="
	test? ( sys-apps/coreboot-utils )
"

src_unpack() {
	platform_src_unpack
	cd "${S}" || die
	unpack "${A}"
}

src_install() {
	platform_src_install

	# install the init script
	if use systemd; then
		systemd_dounit init/vpd-log.service
		systemd_enable_service boot-services.target vpd-log.service
	fi
}

platform_pkg_test() {
	platform test_all

	# This is not a gtest binary; avoid platform_test appending
	# gtest-specific args.
	PLATFORM_PARALLEL_GTEST_TEST="no" \
		platform_test run "tests/run_tests"
}
