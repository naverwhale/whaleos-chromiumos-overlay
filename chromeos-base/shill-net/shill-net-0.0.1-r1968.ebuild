# Copyright 2020 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="683af9ca5985625165cd5910f7443899120e401d"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "29678b000d40c40e8c66efe0f339147f3439f99d" "43e0d3b5bf2c4f82391d5848c6b93fe388a0c215" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE="common-mk net-base shill .gn"

PLATFORM_SUBDIR="shill/net"

inherit cros-workon platform

DESCRIPTION="Shill networking component interface library"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/shill/net"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="fuzzer"

COMMON_DEPEND="
	chromeos-base/minijail:=
	chromeos-base/net-base:=
"
DEPEND="
	${COMMON_DEPEND}
	dev-libs/re2:=
"
RDEPEND="
	${COMMON_DEPEND}
	!<chromeos-base/shill-0.0.5
"

src_install() {
	platform_src_install

	# Generate and install libshill-net pkgconfig.
	insinto "/usr/$(get_libdir)/pkgconfig"
	local v="$(libchrome_ver)"
	./preinstall.sh "${OUT}" "${v}"
	doins "${OUT}/lib/libshill-net.pc"

	local platform_network_component_id="167325"
	local platform_wifi_component_id="893827"

	# These each have different listed component ids.
	platform_fuzzer_install "${S}"/../OWNERS "${OUT}/netlink_attribute_list_fuzzer" \
		--comp "${platform_network_component_id}"
	platform_fuzzer_install "${S}"/../OWNERS "${OUT}/nl80211_message_fuzzer" \
		--comp "${platform_wifi_component_id}"
}

platform_pkg_test() {
	platform test_all
}
