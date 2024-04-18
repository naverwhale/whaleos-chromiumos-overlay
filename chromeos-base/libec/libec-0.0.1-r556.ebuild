# Copyright 2020 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("891cacbe24dacb2b2baaecb7a2d5793ccc9f9a35" "8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "c155beff979e6b3791a7119172c6c443a2ec5c9e" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_USE_VCSID="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="biod common-mk libec .gn"

PLATFORM_SUBDIR="libec"

inherit cros-workon platform

DESCRIPTION="Embedded Controller Library for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/libec"

LICENSE="BSD-Google"
KEYWORDS="*"

COMMON_DEPEND="
	chromeos-base/chromeos-ec-headers:=
	chromeos-base/power_manager-client:=
	dev-cpp/abseil-cpp:=
	virtual/libusb:1=
"

RDEPEND="
	${COMMON_DEPEND}
	"

DEPEND="
	${COMMON_DEPEND}
	chromeos-base/system_api
"

src_install() {
	platform_src_install

	# Install fuzzers.
	local fuzzer_component_id="782045"
	local fuzz_targets=(
		"libec_ec_panicinfo_fuzzer"
	)
	local fuzz_target
	for fuzz_target in "${fuzz_targets[@]}"; do
		platform_fuzzer_install "${S}"/OWNERS "${OUT}"/"${fuzz_target}" \
			--comp "${fuzzer_component_id}"
	done
}

platform_pkg_test() {
	platform test_all
}
