# Copyright 2016 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "891cacbe24dacb2b2baaecb7a2d5793ccc9f9a35" "570bac59c3e6ef5c5c131d4b21e2e095da7c9bbc" "c155beff979e6b3791a7119172c6c443a2ec5c9e" "6d2e5c63a225d587ac97104c5edd96819e6a95a2" "1268480d08437246442187941fe41c4d00a5c3df" "959c1e97be6bae86cb10faba3c2f864a7b3f842b" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_USE_VCSID="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk biod chromeos-config libec libhwsec libhwsec-foundation metrics .gn"

PLATFORM_SUBDIR="biod"

inherit cros-fuzzer cros-sanitizers cros-workon cros-unibuild platform \
	tmpfiles udev user

DESCRIPTION="Biometrics Daemon for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/biod/README.md"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="
	factory_branch
	fp_on_power_button
	fpmcu_firmware_bloonchipper
	fpmcu_firmware_dartmonkey
	fpmcu_firmware_helipilot
	fpmcu_firmware_nami
	fpmcu_firmware_nocturne
	fuzzer
"
# We must depend on libusb because libec headers make use of libusb.
COMMON_DEPEND="
	chromeos-base/chromeos-config-tools:=
	chromeos-base/libec:=
	chromeos-base/libhwsec:=[test?]
	chromeos-base/libhwsec-foundation:=
	>=chromeos-base/metrics-0.0.1-r3152:=
	chromeos-base/vboot_reference:=
	dev-libs/protobuf:=
	sys-apps/flashmap:=
	virtual/libusb:1=
"

# For biod_client_tool. The biod_proxy library will be built on all boards but
# biod_client_tool will be built only on boards with biod.
COMMON_DEPEND+="
	chromeos-base/biod_proxy:=
"

# The crosec-legacy-drv package is a pinned version of flashrom
# for production firmware updates.
RDEPEND="
	${COMMON_DEPEND}
	sys-apps/crosec-legacy-drv:=
	!factory_branch? ( virtual/chromeos-firmware-fpmcu )
	"

# Release branch firmware.
# The USE flags below come from USE_EXPAND variables.
# See third_party/chromiumos-overlay/profiles/base/make.defaults.
RDEPEND+="
	!factory_branch? (
		fpmcu_firmware_bloonchipper? ( sys-firmware/chromeos-fpmcu-release-bloonchipper )
		fpmcu_firmware_dartmonkey? ( sys-firmware/chromeos-fpmcu-release-dartmonkey )
		fpmcu_firmware_helipilot? ( sys-firmware/chromeos-fpmcu-release-helipilot )
		fpmcu_firmware_nami? ( sys-firmware/chromeos-fpmcu-release-nami )
		fpmcu_firmware_nocturne? ( sys-firmware/chromeos-fpmcu-release-nocturne )
	)
"

DEPEND="
	${COMMON_DEPEND}
	chromeos-base/chromeos-ec-headers:=
	chromeos-base/power_manager-client:=
	chromeos-base/system_api:=[fuzzer?]
	dev-libs/openssl:=
"

BDEPEND="
	chromeos-base/minijail
"

pkg_setup() {
	enewuser biod
	enewgroup biod
	enewgroup fpdev
}

src_install() {
	platform_src_install

	udev_dorules udev/99-biod.rules

	dotmpfiles tmpfiles.d/*.conf

	# Set up cryptohome daemon mount store in daemon's mount
	# namespace.
	local daemon_store="/etc/daemon-store/biod"
	dodir "${daemon_store}"
	fperms 0700 "${daemon_store}"
	fowners biod:biod "${daemon_store}"

	local fuzzer_component_id="782045"
	platform_fuzzer_install "${S}/OWNERS" "${OUT}"/biod_storage_fuzzer --comp "${fuzzer_component_id}"

	platform_fuzzer_install "${S}/OWNERS" "${OUT}"/biod_crypto_validation_value_fuzzer --comp "${fuzzer_component_id}"
}

platform_pkg_test() {
	platform test_all
}
