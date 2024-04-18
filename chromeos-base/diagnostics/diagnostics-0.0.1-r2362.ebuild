# Copyright 2018 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "570bac59c3e6ef5c5c131d4b21e2e095da7c9bbc" "03fa9ec95f636176973ba08b7aa1c60d84e4b1d9" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
# TODO(crbug.com/1044813): Remove chromeos-config once its public headers are fixed.
CROS_WORKON_SUBTREE="common-mk chromeos-config diagnostics .gn"

PLATFORM_SUBDIR="diagnostics"

inherit cros-workon cros-unibuild platform udev user

DESCRIPTION="Device telemetry and diagnostics for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/diagnostics"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="fuzzer wilco mesa_reven diagnostics dlc"

COMMON_DEPEND="
	acct-user/cros_healthd
	acct-group/cros_healthd
	chromeos-base/bootstat:=
	chromeos-base/chromeos-config-tools:=
	chromeos-base/libec:=
	chromeos-base/metrics:=
	chromeos-base/minijail:=
	chromeos-base/missive:=
	chromeos-base/mojo_service_manager:=
	chromeos-base/spaced
	wilco? (
		dev-cpp/abseil-cpp:=
	)
	dev-libs/glib:=
	dev-libs/libevdev:=
	dev-libs/protobuf:=
	dev-libs/re2:=
	net-libs/grpc:=
	virtual/libudev:=
	sys-apps/pciutils:=
	virtual/libusb:1=
	virtual/opengles:=
	sys-apps/fwupd:=
	sys-apps/rootdev:=
	sys-apps/util-linux:=
	x11-libs/libdrm:=
"

DEPEND="
	${COMMON_DEPEND}
	chromeos-base/attestation-client:=
	chromeos-base/chromeos-ec-headers:=
	chromeos-base/debugd-client:=
	chromeos-base/dlcservice-client:=
	chromeos-base/libiioservice_ipc:=
	chromeos-base/power_manager-client:=
	chromeos-base/tpm_manager-client:=
	chromeos-base/system_api:=[fuzzer?]
	media-sound/adhd:=
	x11-drivers/opengles-headers:=
"

# TODO(b/273184171): Remove chromeos-base/ec-utils once we don't rely on ectool.
# TODO(b/271544868): Remove net-wireless/iw once we find alternatives.
RDEPEND="
	${COMMON_DEPEND}
	chromeos-base/crash-reporter
	chromeos-base/ec-utils
	chromeos-base/iioservice
	dev-util/stressapptest
	net-wireless/iw
	wilco? (
		chromeos-base/chromeos-dtc-vm
		chromeos-base/vpd
	)
	dlc? (
		chromeos-base/fio-dlc
	)
"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
	chromeos-base/minijail
	dev-libs/protobuf
	net-libs/grpc
"

pkg_preinst() {
	enewgroup cros_ec-access
	enewgroup fpdev
	enewuser healthd_ec
	enewgroup healthd_ec
	enewuser healthd_fp
	enewgroup healthd_fp
	enewuser healthd_evdev
	enewgroup healthd_evdev
	enewuser healthd_psr
	enewgroup healthd_psr
	enewgroup mei-access

	if use wilco; then
		enewuser wilco_dtc
		enewgroup wilco_dtc
	fi
}

src_install() {
	platform_src_install

	if use wilco; then
		# Install udev rules.
		udev_dorules udev/99-ec_driver_files.rules
	fi

	# Install udev rules.
	udev_dorules udev/99-chown_dmi_dir.rules
	udev_dorules udev/99-mei_driver_files.rules

	# Install fuzzers.
	local fuzzer_component_id="982097"
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/fetch_system_info_fuzzer \
		--comp "${fuzzer_component_id}"
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/crash_events_uploads_log_parser_fuzzer \
		--comp "${fuzzer_component_id}"

	# TODO(b/299052079): Remove mojom file after completing hotline migration.
	insinto /usr/include/cros_healthd-client/diagnostics/mojom/public
	doins "${S}"/mojom/public/cros_healthd_probe.mojom
	doins "${OUT}"/gen/include/diagnostics/mojom/public/cros_healthd_probe.mojom-module
}

platform_pkg_test() {
	platform test_all
}
