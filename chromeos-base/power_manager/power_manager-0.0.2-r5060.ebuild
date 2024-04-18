# Copyright 2014 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "570bac59c3e6ef5c5c131d4b21e2e095da7c9bbc" "9e460cea0783689eb1e1588f5b4101da39da9b79" "433938c209efa6b28167ed132ea135f2fe1af94a" "c155beff979e6b3791a7119172c6c443a2ec5c9e" "4590aa4213893b0df46f17778b4daa4d999277ce" "959c1e97be6bae86cb10faba3c2f864a7b3f842b" "05a052ec9a484e721478c7bb3e5e8e76c4ddc016" "0dd1a6e4665a8683c327f6193f5cdaf6e768e402" "e8b01b0b25a2a1b303f3db00fcefbec5758c1c19" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_USE_VCSID="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk chromeos-config featured iioservice libec libsar metrics mojo_service_manager power_manager shill/dbus/client .gn"

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="power_manager"

inherit tmpfiles cros-workon cros-unibuild platform systemd udev user

DESCRIPTION="Power Manager for Chromium OS"
HOMEPAGE="http://dev.chromium.org/chromium-os/packages/power_manager"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="-als cellular +cras cros_embedded +display_backlight fuzzer -has_keyboard_backlight iioservice iioservice_proximity -keyboard_includes_side_buttons keyboard_convertible_no_side_buttons -legacy_power_button -powerd_manual_eventlog_add +powerknobs systemd test +touchpad_wakeup -touchscreen_wakeup unibuild wilco qrtr"
REQUIRED_USE="
	?? ( keyboard_includes_side_buttons keyboard_convertible_no_side_buttons )
	unibuild
"

COMMON_DEPEND="
	chromeos-base/chromeos-config-tools:=
	chromeos-base/featured:=
	chromeos-base/libec:=
	chromeos-base/libiioservice_ipc:=
	chromeos-base/libsar:=[test?]
	>=chromeos-base/metrics-0.0.1-r3152:=
	chromeos-base/ml-client:=
	chromeos-base/mojo_service_manager:=
	chromeos-base/power_manager-client:=
	chromeos-base/shill-dbus-client:=
	chromeos-base/tpm_manager-client:=
	dev-cpp/abseil-cpp:=
	dev-libs/libnl:=
	dev-libs/protobuf:=
	dev-libs/re2:=
	cras? ( media-sound/adhd:= )
	sys-fs/udev:=
	virtual/libusb:=
	virtual/udev
	cellular? ( net-misc/modemmanager-next:= )
	sys-apps/dbus:="

RDEPEND="${COMMON_DEPEND}
	chromeos-base/libiioservice_ipc:=
	powerd_manual_eventlog_add? ( sys-apps/coreboot-utils )
	qrtr? ( net-libs/libqrtr:= )
"

DEPEND="${COMMON_DEPEND}
	chromeos-base/chromeos-ec-headers:=
	chromeos-base/system_api:=[fuzzer?]
	qrtr? ( sys-apps/upstart:= )
"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
"

pkg_setup() {
	# Create the 'power' user and group here in pkg_setup as src_install needs
	# them to change the ownership of power manager files.
	enewuser "power"
	enewgroup "power"
	# Ensure that this group exists so that power_manager can access
	# /dev/cros_ec.
	enewgroup "cros_ec-access"
	cros-workon_pkg_setup
}

src_install() {
	platform_src_install

	# Binaries for production
	fowners root:power /usr/bin/powerd_setuid_helper
	fperms 4750 /usr/bin/powerd_setuid_helper

	# Preferences
	insinto /usr/share/power_manager
	doins default_prefs/*
	use als && doins optional_prefs/has_ambient_light_sensor
	use cras && doins optional_prefs/use_cras
	use display_backlight || doins optional_prefs/external_display_only
	use has_keyboard_backlight && doins optional_prefs/has_keyboard_backlight
	use legacy_power_button && doins optional_prefs/legacy_power_button
	use powerd_manual_eventlog_add && doins optional_prefs/manual_eventlog_add

	# udev scripts and rules.
	exeinto "$(get_udevdir)"
	doexe udev/*.sh
	udev_dorules udev/*.rules

	if use powerknobs; then
		udev/gen_autosuspend_rules.py > "${T}"/98-autosuspend.rules || die
		udev_dorules "${T}"/98-autosuspend.rules
		udev_dorules udev/optional/98-powerknobs.rules
		dobin udev/optional/set_blkdev_pm
	fi
	if use keyboard_includes_side_buttons; then
		udev_dorules udev/optional/93-powerd-tags-keyboard-side-buttons.rules
	elif use keyboard_convertible_no_side_buttons; then
		udev_dorules udev/optional/93-powerd-tags-keyboard-convertible.rules
	fi

	if ! use touchpad_wakeup; then
		udev_dorules udev/optional/93-powerd-tags-no-touchpad-wakeup.rules
	else
		udev_dorules udev/optional/93-powerd-tags-unibuild-touchpad-wakeup.rules
	fi

	if use touchscreen_wakeup; then
		udev_dorules udev/optional/93-powerd-tags-touchscreen-wakeup.rules
	else
		udev_dorules udev/optional/93-powerd-tags-unibuild-touchscreen-wakeup.rules
	fi

	if use wilco; then
		udev_dorules udev/optional/93-powerd-wilco-ec-files.rules

		exeinto /usr/share/cros/init/optional
		doexe init/shared/optional/powerd-pre-start-wilco.sh
	fi

	# Init scripts
	if use systemd; then
		systemd_dounit init/systemd/*.service
		systemd_enable_service boot-services.target powerd.service
		systemd_enable_service system-services.target report-power-metrics.service
		dotmpfiles init/systemd/powerd_directories.conf
	else
		insinto /etc/init
		insopts -m0644
		doins init/upstart/*.conf
	fi

	# Install fuzz targets.
	local fuzzer
	for fuzzer in "${OUT}"/*_fuzzer; do
		local fuzzer_component_id="167191"
		platform_fuzzer_install "${S}"/OWNERS "${fuzzer}" \
			--comp "${fuzzer_component_id}"
	done
}

platform_pkg_test() {
	platform test_all
}
