# Copyright 2020 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="04097b9df3be67662e26f4a7452ddbf989a7158b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "959c1e97be6bae86cb10faba3c2f864a7b3f842b" "db64459c4b4ba3f505643569b67416aec469a3a5" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk metrics minios .gn"

PLATFORM_SUBDIR="minios"

inherit cros-workon platform

DESCRIPTION="The miniOS main logic."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/minios/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="
	lvm_stateful_partition
	minios
"
REQUIRED_USE="minios"

COMMON_DEPEND="
	chromeos-base/metrics:=
	chromeos-base/shill-client:=
	chromeos-base/update_engine-client:=
	x11-libs/libxkbcommon:=
	x11-misc/xkeyboard-config:=
"

RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}
	chromeos-base/system_api:=
	chromeos-base/vboot_reference:=
"

platform_pkg_test() {
	platform_test "run" "${OUT}/minios_test"
}

src_install() {
	platform_src_install

	into "/build/initramfs"
	dobin "${OUT}/minios"
	dobin "${OUT}/minios_client"
	dobin scripts/root_partition_for_recovery
	dobin scripts/stateful_partition_for_recovery

	if use lvm_stateful_partition; then
		# shellcheck disable=SC2016
		# Replace lvm_stateful flag in stateful_partition_for_recovery to true.
		sed -i \
			'/DEFINE_boolean lvm_stateful "/s:\${FLAGS_FALSE}:\${FLAGS_TRUE}:' \
			"${D}/build/initramfs/bin/stateful_partition_for_recovery" ||
			die "Failed to set lvm_stateful in stateful_partition_for_recovery"
	fi

	# D-Bus configuration
	insinto "/build/initramfs/etc/dbus-1/system.d"
	doins org.chromium.MiniOs.conf
	insinto "/build/initramfs/"
	doins -r ramfs/*
}
