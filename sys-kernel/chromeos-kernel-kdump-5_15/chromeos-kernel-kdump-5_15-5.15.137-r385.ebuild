# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="24e6bf8e5d11042ea483f095f6df4ddbd747248c"
CROS_WORKON_TREE="be01cb066c3f3c937c3073f01aca4d0bac76b989"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/v5.15"
CROS_WORKON_EGIT_BRANCH="chromeos-5.15"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel

DESCRIPTION="Mini-kernel that is kexeced during panics"
KEYWORDS="*"
# u-root + lvm2 + kernel licenses.
LICENSE="GPL-2 BSD-2 LGPL-2.1 BSD"

DEPEND="
	sys-boot/kdump-ramfs
"

src_configure() {
	# shellcheck disable=SC2154 # CHROMEOS_KERNEL_SPLITCONFIG defined in cros-kernel
	CHROMEOS_KERNEL_FAMILY="kdump" chromeos/scripts/prepareconfig "${CHROMEOS_KERNEL_SPLITCONFIG}" "$(get_build_cfg)" || die
	echo "CONFIG_INITRAMFS_SOURCE=\"${SYSROOT}/usr/share/kdump/boot/kdump-rfs.cpio\"" >> "$(get_build_cfg)"
	kmake olddefconfig
}

KDUMP_FOLDER="/usr/share/kdump"

src_install() {
	mkdir -p "${T}/boot"
	kmake INSTALL_PATH="${T}/boot" install

	# Image type used by kexec, depending on the architecture.
	case "${ARCH}" in
	arm | arm64)
		IMAGE=Image
		;;
	*)
		IMAGE=vmlinuz
		;;
	esac

	insinto "${KDUMP_FOLDER}/boot"
	doins "${T}/boot/${IMAGE}-$(kernelrelease)"
	dosym "${KDUMP_FOLDER}/boot/${IMAGE}-$(kernelrelease)" "${KDUMP_FOLDER}/boot/kdump-image"
}
