# Copyright 2022 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="be2dcdccabb39ebf7337a4c099163441963e6e8b"
CROS_WORKON_TREE="b04e7c05a8489a4dbcee133b545196d5c52c8608"
CROS_WORKON_PROJECT="chromiumos/third_party/OP-TEE/optee_os"
CROS_WORKON_LOCALNAME="optee_os"
CROS_WORKON_DESTDIR="${S}"

inherit cros-workon coreboot-sdk

DESCRIPTION="Op-Tee Secure OS TA Dev Kit"
HOMEPAGE="https://www.github.com/OP-TEE/optee_os"

LICENSE="BSD"
KEYWORDS="*"
CHIPSETS=(mt8195 mt8188)
IUSE="
	coreboot-sdk
	${CHIPSETS[*]/#/optee_}
"
# Make sure we don't use SDK gcc anymore.
REQUIRED_USE="coreboot-sdk"

src_configure() {
	local chipset
	for chipset in "${CHIPSETS[@]}"; do
		if use "optee_${chipset}"; then
			export PLATFORM="mediatek-${chipset}"
			export MTK_CHIP_NAME="${chipset}"
			break
		fi
	done
	[[ -n ${PLATFORM} ]] || die "unhandled chipset"
	export CROSS_COMPILE64=${COREBOOT_SDK_PREFIX_arm64}
	export OPTEE_PATH="${S}"
	export O="${WORKDIR}/out"
	export CFG_ARM64_core="y"
	export DEBUG="0"
	export CFG_EARLY_TA="y"
	export ARCH="arm"

	# CFLAGS/CXXFLAGS/CPPFLAGS/LDFLAGS are set for userland, but those options
	# don't apply properly to firmware so unset them.
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS
}

src_compile() {
	emake ta-targets=ta_arm64 ta_dev_kit
}

src_install() {
	# Install the dev kit used when building TAs (makefiles, header files, etc.).
	insinto /build/share/optee
	doins -r "${WORKDIR}/out/export-ta_arm64"
}
