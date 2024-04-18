# Copyright 2012 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "29678b000d40c40e8c66efe0f339147f3439f99d" "f09fe585edb705a0b8d59e37b176c77167d136eb" "9e460cea0783689eb1e1588f5b4101da39da9b79" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk net-base permission_broker featured .gn"

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="permission_broker"

# Do not run test parallelly until unit tests are fixed.
# shellcheck disable=SC2034
PLATFORM_PARALLEL_GTEST_TEST="no"

inherit cros-workon platform udev user

DESCRIPTION="Permission Broker for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/permission_broker/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="cfm_enabled_device fuzzer"

COMMMON_DEPEND="
	chromeos-base/featured:=
	chromeos-base/net-base:=
	chromeos-base/patchpanel-client:=
	chromeos-base/system_api:=[fuzzer?]
	sys-apps/dbus:=
	virtual/libusb:1
	virtual/libudev:=
"

RDEPEND="
	${COMMMON_DEPEND}
	virtual/udev
"
DEPEND="${COMMMON_DEPEND}
	sys-kernel/linux-headers:=
"

BDEPEND="
	chromeos-base/chromeos-dbus-bindings
"

src_install() {
	platform_src_install

	dobin "${OUT}"/permission_broker

	# Install upstart configuration
	insinto /etc/init
	doins permission_broker.conf

	# DBus configuration
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.PermissionBroker.conf

	# Udev rules for hidraw nodes
	udev_dorules "${FILESDIR}/99-hidraw.rules"

	# Fuzzer.
	local fuzzer_component_id="156085"
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/port_tracker_fuzzer \
		--comp "${fuzzer_component_id}"
}

platform_pkg_test() {
	local tests=(
		permission_broker_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

pkg_preinst() {
	enewuser "devbroker"
	enewgroup "devbroker"
}
