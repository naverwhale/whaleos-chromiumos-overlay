# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT=("761155c5b064911ba3437d5f8a49ecdb98a3656e" "83955fb8c712b95c8f0f8dfc4fe6557415794184")
CROS_WORKON_TREE=("0ffe5d562c7eac3fd45117dbcf6f565e03bad79c" "9ecd116aad2a8a57a7e25a9f7155db8a87b5c194")
CROS_WORKON_LOCALNAME=("platform2" "third_party/tpm2")
CROS_WORKON_PROJECT=("chromiumos/platform2" "chromiumos/third_party/tpm2")
CROS_WORKON_SUBTREE=("hwsec-optee-ta" "")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/third_party/tpm2")

inherit cros-workon coreboot-sdk

DESCRIPTION="Trusted Application for HWSec for Op-Tee on ARM"

LICENSE="BSD-Google"
KEYWORDS="*"
CHIPSETS=(mt8195 mt8188)
IUSE="
	coreboot-sdk
	${CHIPSETS[*]/#/optee_}
"

RDEPEND="chromeos-base/optee_client:="

DEPEND="
	${RDEPEND}
	sys-firmware/optee_os_tadevkit:=
"

# Make sure we don't use SDK gcc anymore.
REQUIRED_USE="coreboot-sdk"

src_configure() {
	local chipset
	for chipset in "${CHIPSETS[@]}"; do
		if use "optee_${chipset}"; then
			export PLATFORM="mediatek-${chipset}"
			break
		fi
	done
	[[ -n ${PLATFORM} ]] || die "unhandled chipset"
	export OPTEE_DIR="${SYSROOT}/build/share/optee"
	export CROSS_COMPILE64=${COREBOOT_SDK_PREFIX_arm64}
	export CROSS_COMPILE_core=${COREBOOT_SDK_PREFIX_arm64}
	export TA_DEV_KIT_DIR=${OPTEE_DIR}/export-ta_arm64
	export TA_OUTPUT_DIR="${WORKDIR}/out"

	# CFLAGS/CXXFLAGS/CPPFLAGS/LDFLAGS are set for userland, but those options
	# don't apply properly to firmware so unset them.
	unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS
}

src_compile() {
	emake -C "${S}/platform2/hwsec-optee-ta"
}

src_install() {
	insinto /lib/optee_armtz
	doins "${WORKDIR}/out/ed800e33-3c58-4cae-a7c0-fd160e35e00d.ta"
}
