# Copyright 2022 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="be2dcdccabb39ebf7337a4c099163441963e6e8b"
CROS_WORKON_TREE="b04e7c05a8489a4dbcee133b545196d5c52c8608"
CROS_WORKON_PROJECT="chromiumos/third_party/OP-TEE/optee_os"
CROS_WORKON_LOCALNAME="optee_os"
CROS_WORKON_DESTDIR="${S}"

inherit cros-workon coreboot-sdk

DESCRIPTION="Op-Tee Secure OS"
HOMEPAGE="https://www.github.com/OP-TEE/optee_os"

LICENSE="BSD"
KEYWORDS="*"
CHIPSETS=(mt8195 mt8188)
IUSE="
	coreboot-sdk
	${CHIPSETS[*]/#/optee_}
"

# Make sure we don't use SDK gcc anymore.
REQUIRED_USE="
	coreboot-sdk
	^^ ( ${CHIPSETS[*]/#/optee_} )
"

src_configure() {
	local chipset
	for chipset in "${CHIPSETS[@]}"; do
		if use "optee_${chipset}"; then
			export PLATFORM="mediatek-${chipset}"
			export MTK_CHIP_NAME="${chipset}"
			break
		fi
	done
	[[ -n "${PLATFORM}" ]] || die "unhandled chipset"
	export CROSS_COMPILE64=${COREBOOT_SDK_PREFIX_arm64}
	export OPTEE_PATH="${S}"
	export O="${WORKDIR}/out"
	export CFG_ARM64_core="y"
	export DEBUG="0"
	export ARCH="arm"
	export CFG_TEE_CORE_LOG_LEVEL="0"

	export CFG_CORE_ASLR="n"
	export CFG_UART_ENABLE="y"
	export CFG_DRAM_SIZE="0x200000000"
	export CFG_TZDRAM_START="0x43000000"
	export CFG_TZDRAM_SIZE="0x05000000"
	export CFG_TEE_RAM_VA_SIZE="0x04C00000"
	export FBSIZE="0x03200000"
	export CFG_CORE_HEAP_SIZE="1048576"
	export CFG_STACK_THREAD_EXTRA="10240"
	export CFG_NUM_THREADS="8"
	export CFG_WITH_USER_TA="y"
	export CFG_CORE_ASYNC_NOTIF="y"
	export CFG_CORE_ASYNC_NOTIF_GIC_INTID="579"
	export CFG_ENABLE_GROUP1S="y"
	export CFG_CACHE_API="y"

	export CFG_CORE_RESERVED_SHM="n"
	export CFG_RESERVED_VASPACE_SIZE="0x1F000000"
	export CFG_WITH_STATS="y"

	# CFLAGS/CXXFLAGS/CPPFLAGS/LDFLAGS are set for userland, but those options
	# don't apply properly to firmware so unset them.
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS
}

src_compile() {
	emake ta-targets=ta_arm64 all

	# Concatenate the header and pager, this is the format we use from the kernel
	# to send to TF-A to load Op-Tee via an SMC.
	cat "${WORKDIR}/out/core/tee-header_v2.bin" \
		"${WORKDIR}/out/core/tee-pager_v2.bin" \
		> "${WORKDIR}/out/tee.bin"
}

src_install() {
	# Copy the Op-Tee ELF file for inclusion as firmware in the rootfs.
	insinto /lib/firmware/optee
	doins "${WORKDIR}/out/tee.bin"
}
