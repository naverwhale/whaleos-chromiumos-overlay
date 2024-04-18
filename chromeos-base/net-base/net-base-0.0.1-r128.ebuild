# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "29678b000d40c40e8c66efe0f339147f3439f99d" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk net-base .gn"

PLATFORM_SUBDIR="net-base"
# Do not run test in parallel for net-base by default. There doesn't seem to be
# too much benefit on speed now but affects the debugging experience.
# shellcheck disable=SC2034
PLATFORM_PARALLEL_GTEST_TEST="no"

inherit cros-workon libchrome platform

DESCRIPTION="Networking primitive library"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/net-base/"
LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="fuzzer test"

COMMON_DEPEND="
	test? ( dev-libs/re2:= )
	net-dns/c-ares:=
"
DEPEND="
	${COMMON_DEPEND}
"
RDEPEND="
	${COMMON_DEPEND}
"

src_install() {
	platform_src_install

	local platform_network_component_id="167325"
	platform_fuzzer_install "${S}"/OWNERS "${OUT}/rtnl_handler_fuzzer" \
		--comp "${platform_network_component_id}"
}

platform_pkg_test() {
	platform test_all
}
