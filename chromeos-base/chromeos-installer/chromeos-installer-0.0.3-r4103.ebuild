# Copyright 2012 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT="52c9399743d3aff4e55f3e0e7ef2af7a7b3b1434"
CROS_WORKON_TREE=("570bac59c3e6ef5c5c131d4b21e2e095da7c9bbc" "8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "6650fe935b152407e700f4b30130e8ff02bf69aa" "959c1e97be6bae86cb10faba3c2f864a7b3f842b" "822335b4659da793507c0a091315bb2d942e1bb4" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="chromeos-config common-mk installer metrics verity .gn"

PLATFORM_SUBDIR="installer"
# Do not run test parallelly until unit tests are fixed.
# shellcheck disable=SC2034
PLATFORM_PARALLEL_GTEST_TEST="no"

inherit cros-workon platform systemd

DESCRIPTION="Chrome OS Installer"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/installer/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="
	cros_embedded
	enable_slow_boot_notify
	-mtd
	pam
	systemd
	lvm_stateful_partition
	postinstall_cgpt_repair
	postinstall_config_efi_and_legacy
	manage_efi_boot_entries
	postinst_metrics
	reven_partition_migration
"

COMMON_DEPEND="
	chromeos-base/vboot_reference
	chromeos-base/verity
	manage_efi_boot_entries? ( chromeos-base/chromeos-config sys-libs/efivar )
	postinst_metrics? ( chromeos-base/metrics )
"

DEPEND="${COMMON_DEPEND}
	dev-libs/openssl:0=
"

RDEPEND="${COMMON_DEPEND}
	pam? ( app-admin/sudo )
	chromeos-base/chromeos-common-script
	!cros_embedded? ( chromeos-base/chromeos-storage-info )
	dev-libs/openssl:0=
	dev-util/shflags
	sys-apps/rootdev
	sys-apps/util-linux
	sys-apps/which
	sys-fs/e2fsprogs"

platform_pkg_test() {
	platform_test "run" "${OUT}/cros_installer_test"
}

src_install() {
	platform_src_install

	# Install init scripts. Non-systemd case is defined in BUILD.gn.
	if use systemd; then
		systemd_dounit init/install-completed.service
		systemd_enable_service boot-services.target install-completed.service
		systemd_dounit init/crx-import.service
		systemd_enable_service system-services.target crx-import.service
	fi
}
