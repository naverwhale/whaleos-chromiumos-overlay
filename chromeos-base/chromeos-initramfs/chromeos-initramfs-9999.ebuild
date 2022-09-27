# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
CROS_WORKON_PROJECT="chromiumos/platform/initramfs"
CROS_WORKON_LOCALNAME="platform/initramfs"
CROS_WORKON_OUTOFTREE_BUILD="1"

inherit cros-workon cros-board cros-constants

DESCRIPTION="Create Chrome OS initramfs"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/initramfs/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"
IUSE="+cros_ec_utils detachable device_tree +interactive_recovery"
IUSE="${IUSE} legacy_firmware_ui -mtd +power_management"
IUSE="${IUSE} physical_presence_power physical_presence_recovery"
IUSE="${IUSE} unibuild +oobe_config"

# Build Targets
TARGETS_IUSE="
	factory_netboot_ramfs
	factory_shim_ramfs
	hypervisor_ramfs
	recovery_ramfs
	minios_ramfs
"
IUSE+=" ${TARGETS_IUSE}"
REQUIRED_USE="|| ( ${TARGETS_IUSE} )"

# Packages required for building recovery initramfs.
RECOVERY_DEPENDS="
	chromeos-base/chromeos-installer
	chromeos-base/common-assets
	chromeos-base/vboot_reference
	chromeos-base/vpd
	sys-apps/flashrom
	sys-apps/pv
	virtual/assets
	virtual/chromeos-regions
	"

MINIOS_DEPENDS="
	chromeos-base/minios
	dev-util/strace
	net-misc/curl
	net-misc/dhcp
	net-misc/dhcpcd
	net-wireless/wpa_supplicant-cros
	chromeos-base/minijail
	chromeos-base/chromeos-installer
	chromeos-base/factory_installer
	chromeos-base/common-assets
	chromeos-base/vboot_reference
	chromeos-base/vpd
	sys-apps/flashrom
	sys-apps/pv
	virtual/assets
	virtual/chromeos-regions
	"

# Packages required for building factory installer shim initramfs.
FACTORY_SHIM_DEPENDS="
	chromeos-base/factory_installer
	chromeos-base/vboot_reference
	"

# Packages required for building factory netboot installer initramfs.
FACTORY_NETBOOT_DEPENDS="
	app-arch/lbzip2
	app-arch/pigz
	app-arch/sharutils
	app-misc/jq
	app-shells/bash
	chromeos-base/chromeos-base
	chromeos-base/chromeos-installer
	chromeos-base/chromeos-installshim
	chromeos-base/chromeos-storage-info
	chromeos-base/ec-utils
	chromeos-base/factory_installer
	chromeos-base/vboot_reference
	chromeos-base/vpd
	dev-libs/openssl:0=
	dev-util/shflags
	dev-util/xxd
	net-misc/curl
	net-misc/htpdate
	net-misc/uftp
	net-misc/wget
	sys-apps/coreutils
	sys-apps/flashrom
	sys-apps/iproute2
	sys-apps/mosys
	sys-apps/util-linux
	sys-fs/dosfstools
	sys-fs/e2fsprogs
	sys-libs/ncurses
	virtual/udev
	"

# Packages required for building hypervisor initramfs.
HYPERVISOR_DEPENDS="
	chromeos-base/crosvm
	chromeos-base/sirenia
	virtual/linux-sources
	"

DEPEND="
	factory_netboot_ramfs? ( ${FACTORY_NETBOOT_DEPENDS} )
	factory_shim_ramfs? ( ${FACTORY_SHIM_DEPENDS} )
	recovery_ramfs? ( ${RECOVERY_DEPENDS} )
	hypervisor_ramfs? ( ${HYPERVISOR_DEPENDS} )
	minios_ramfs? ( ${MINIOS_DEPENDS} )
	sys-apps/busybox[-make-symlinks]
	sys-fs/lvm2
	virtual/chromeos-bsp-initramfs
	chromeos-base/chromeos-init
	sys-apps/frecon-lite
	power_management? ( chromeos-base/power_manager )
	unibuild? ( chromeos-base/chromeos-config )
	chromeos-base/chromeos-config-tools"

RDEPEND=""

BDEPEND="
	hypervisor_ramfs? ( chromeos-base/sirenia-tools )"

src_prepare() {
	export BUILD_LIBRARY_DIR="${CHROOT_SOURCE_ROOT}/src/scripts/build_library"
	export INTERACTIVE_COMPLETE="$(usex interactive_recovery true false)"

	# Need the lddtree from the chromite dir.
	export PATH="${CHROMITE_BIN_DIR}:${PATH}"

	eapply_user
}

src_compile() {
	local deps=()
	use mtd && deps+=(/usr/bin/cgpt)
	if use factory_netboot_ramfs; then
		use power_management && deps+=(/usr/bin/backlight_tool)
	fi

	local targets=()
	for target in ${TARGETS_IUSE}; do
		use "${target}" && targets+=("${target%_ramfs}")
	done
	einfo "Building targets: ${targets[*]}"

	local physical_presence
	if use physical_presence_power ; then
		physical_presence="power"
	elif use physical_presence_recovery ; then
		physical_presence="recovery"
	else
		physical_presence="keyboard"
	fi

	emake SYSROOT="${SYSROOT}" BOARD="$(get_current_board_with_variant)" \
		INCLUDE_FIT_PICKER="$(usex device_tree 1 0)" \
		INCLUDE_ECTOOL="$(usex cros_ec_utils 1 0)" \
		DETACHABLE="$(usex detachable 1 0)" \
		LEGACY_UI="$(usex legacy_firmware_ui 1 0)" \
		UNIBUILD="$(usex unibuild 1 0)" \
		OOBE_CONFIG="$(usex oobe_config 1 0)" \
		PHYSICAL_PRESENCE="${physical_presence}" \
		OUTPUT_DIR="${WORKDIR}" EXTRA_BIN_DEPS="${deps[*]}" \
		LOCALE_LIST="${RECOVERY_LOCALES}" "${targets[@]}"
}

src_install() {
	insinto /var/lib/initramfs
	for target in ${TARGETS_IUSE}; do
		use "${target}" &&
			doins "${WORKDIR}/${target}.cpio.xz"
	done
}
