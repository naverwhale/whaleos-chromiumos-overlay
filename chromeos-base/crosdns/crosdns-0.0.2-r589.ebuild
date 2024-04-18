# Copyright 2018 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "b1bb82ed9358faa9ca08133e02c1be2c887208c0" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE="common-mk crosdns .gn"

PLATFORM_SUBDIR="crosdns"

inherit cros-fuzzer cros-sanitizers cros-workon platform tmpfiles user

DESCRIPTION="Local hostname modifier service for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/crosdns"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="*"
IUSE="+seccomp asan fuzzer"

COMMON_DEPEND="
	chromeos-base/libbrillo:=[asan?,fuzzer?]
	chromeos-base/minijail:="

RDEPEND="${COMMON_DEPEND}"

DEPEND="
	${COMMON_DEPEND}
	chromeos-base/system_api:=[fuzzer?]"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
	chromeos-base/minijail
"

src_install() {
	platform_src_install

	dotmpfiles tmpfiles.d/*.conf

	# fuzzer_component_id is unknown/unlisted
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/hosts_modifier_fuzzer
}

platform_pkg_test() {
	platform test_all
}

pkg_preinst() {
	enewuser "crosdns"
	enewgroup "crosdns"
}
