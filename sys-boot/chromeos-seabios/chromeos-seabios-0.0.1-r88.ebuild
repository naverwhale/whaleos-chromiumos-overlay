# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="27b56c6e94fe37e9308392fefd25ba641d8be496"
CROS_WORKON_TREE="51fbe960a8cabb7fc65a7f0995024c545341e8b3"
CROS_WORKON_PROJECT="chromiumos/third_party/seabios"
CROS_WORKON_EGIT_BRANCH="chromeos-2014.11.03"
CROS_WORKON_LOCALNAME="seabios"

inherit toolchain-funcs cros-workon coreboot-sdk

DESCRIPTION="Open Source implementation of X86 BIOS"
HOMEPAGE="http://www.coreboot.org/SeaBIOS"
LICENSE="GPL-2"
KEYWORDS="-* amd64 x86"
IUSE="coreboot-sdk fwserial"

# Directory where the generated files are looked for and placed.
CROS_FIRMWARE_IMAGE_DIR="/firmware"
CROS_FIRMWARE_ROOT="${SYSROOT%/}${CROS_FIRMWARE_IMAGE_DIR}"

_emake() {
	if ! use coreboot-sdk; then
		local LD="$(tc-getLD).bfd"
		local CC="$(tc-getCC)"
		local AS="$(tc-getAS)"
	else
		local CC=${COREBOOT_SDK_PREFIX_x86_32}gcc
		local LD=${COREBOOT_SDK_PREFIX_x86_32}ld
		local AS=${COREBOOT_SDK_PREFIX_x86_32}as
	fi

	emake \
		CROSS_PREFIX="${CHOST}-" \
		PKG_CONFIG="$(tc-getPKG_CONFIG)" \
		HOSTCC="$(tc-getBUILD_CC)" \
		LD="${LD}" \
		AS="${AS}" \
		CC="${CC} -fuse-ld=bfd" \
		AS="${AS}" \
		"$@"
}

# Build the config for seabios
# Args:
#   $1: Filename of config file
build_config() {
	local cfg="$1"

	# Hard-coded config for zork
	local CONFIG_CONSOLE_UART_BASE_ADDRESS=0xfedc9000
# 	local CONFIG_CONSOLE_SERIAL_115200=y
# 	local CONFIG_DRIVERS_UART_8250MEM=y
# 	local CONFIG_DRIVERS_UART_8250MEM_32=y
# 	local CONFIG_PAYLOAD_CONFIGFILE="$(top)/src/mainboard/google/zork/config_seabios"
	local CONFIG_SEABIOS_DEBUG_LEVEL=-1
	local CONFIG_SEABIOS_VGA_COREBOOT=
	local CONFIG_SEABIOS_THREAD_OPTIONROMS=n

	# This code is taken from the coreboot Makefile
	echo "CONFIG_COREBOOT=y" > "${cfg}"
	echo "CONFIG_DEBUG_SERIAL_MMIO=y" >> "${cfg}"
	echo "CONFIG_DEBUG_SERIAL_MEM_ADDRESS=${CONFIG_CONSOLE_UART_BASE_ADDRESS}" >> "${cfg}"

	if [ "${CONFIG_SEABIOS_THREAD_OPTIONROMS}" != "y" ]; then
		echo "# CONFIG_THREAD_OPTIONROMS is not set" >> "${cfg}"
	fi
	if [ "${CONFIG_SEABIOS_VGA_COREBOOT}" != "y" ]; then
		echo "CONFIG_VGA_COREBOOT=y" >> "${cfg}"
		echo "CONFIG_BUILD_VGABIOS=y" >> "${cfg}"
	fi

	echo "# CONFIG_TCGBIOS is not set" >> "${cfg}"
	if [ "${CONFIG_SEABIOS_DEBUG_LEVEL}" != "-1" ]; then
		echo "CONFIG_DEBUG_LEVEL=${CONFIG_SEABIOS_DEBUG_LEVEL}" >> "${cfg}"
	fi
}

src_compile() {
	local config="base.config"

	build_config "${config}"
	cat "${config}"
	cp "${config}" .config
	_emake olddefconfig
	_emake

	mkdir staging
	cp out/bios.bin.elf staging/seabios.noserial.elf
	cp .config staging/config.seabios.noserial
	# Select which version is the default
	if ! use fwserial; then
		cp out/bios.bin.elf staging/seabios.elf
	fi
	_emake clean

	cp "${config}" .config
	echo "CONFIG_DEBUG_SERIAL=y" >> "${config}"
	_emake olddefconfig
	_emake
	cp out/bios.bin.elf staging/seabios.serial.elf
	if use fwserial; then
		cp out/bios.bin.elf staging/seabios.elf
	fi
	cp  .config staging/config.seabios.serial
	cp "${config}" staging/config.seabios.base
}

src_install() {
	local oprom=$(echo "${CROS_FIRMWARE_ROOT}"/pci????,????.rom)
	local vgabios="out/vgabios.bin"

	insinto /firmware/seabios
	doins staging/seabios*.elf
	doins staging/config*

	# Add additional configuration
	insinto /firmware/seabios/cbfs
	doins chromeos/links
	doins chromeos/bootorder
	insinto /firmware/seabios/etc
	doins chromeos/etc/boot-menu-key
	doins chromeos/etc/boot-menu-message
	doins chromeos/etc/boot-menu-wait
}
