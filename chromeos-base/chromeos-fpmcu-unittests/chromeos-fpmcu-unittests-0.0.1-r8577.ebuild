# Copyright 2020 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

# Increment the "eclass bug workaround count" below when you change
# "cros-ec.eclass" to work around https://issuetracker.google.com/201299127.
#
# eclass bug workaround count: 5

EAPI=7

CROS_WORKON_COMMIT=("3e61925354542ecc7fecaa27be7bc136de55aca3" "0dd679081b9c8bfa2583d74e3a17a413709ea362" "c18f94e3b017104284cd541e553472e62e85e526" "e0d601a57fde7d67a1c771e7d87468faf1f8fe55" "8fa9461cc28e053d66f17132808d287ae51575e2")
CROS_WORKON_TREE=("d145c6a5b65d1accc879042b0754470abb831c21" "d99abee3f825248f344c0638d5f9fcdce114b744" "17878f433c782b4f34ec7180490cdfb371a0fee7" "307ef78893e2eb0851e7d09bb2fd535748bbccf7" "db0717a7f90d588243994b56d4bb206be31cc9a2")
CROS_WORKON_PROJECT=(
	"chromiumos/platform/ec"
	"chromiumos/third_party/cryptoc"
	"external/gitlab.com/libeigen/eigen"
	"external/gob/boringssl/boringssl"
	"external/github.com/google/googletest"
)
CROS_WORKON_LOCALNAME=(
	"platform/ec"
	"third_party/cryptoc"
	"third_party/eigen3"
	"third_party/boringssl"
	"third_party/googletest"
)
CROS_WORKON_DESTDIR=(
	"${S}/platform/ec"
	"${S}/third_party/cryptoc"
	"${S}/third_party/eigen3"
	"${S}/third_party/boringssl"
	"${S}/third_party/googletest"
)

inherit cros-ec cros-workon cros-sanitizers

DESCRIPTION="ChromeOS fingerprint MCU unittest binaries"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libec:=
	dev-embedded/libftdi:=
"

DEPEND="
	${RDEPEND}
"

BDEPEND="
	chromeos-base/vboot_reference
	dev-util/cmake
	dev-util/ninja
"

# Needed to build against EC_BOARDS.
BDEPEND+="
	cross-armv7m-cros-eabi/binutils
	cross-armv7m-cros-eabi/compiler-rt
	cross-armv7m-cros-eabi/libcxx
	cross-armv7m-cros-eabi/newlib
"

# Make sure config tools use the latest schema.
BDEPEND+="
	>=chromeos-base/chromeos-config-host-0.0.2
"

get_target_boards() {
	# TODO(yichengli): Add other FPMCUs once the test lab has them.
	EC_BOARDS=("bloonchipper")
}

src_configure() {
	sanitizers-setup-env
	default
}

src_compile() {
	cros-ec_set_build_env
	get_target_boards

	# TODO(yichengli): Add other FPMCU boards once the test lab has them.
	# NOTE: Any changes here must also be reflected in
	# platform/ec/firmware_builder.py which is used for the ec cq
	local target
	einfo "Building FPMCU unittest binary for targets: ${EC_BOARDS[*]}"
	for target in "${EC_BOARDS[@]}"; do
		emake BOARD="${target}" "${EC_OPTS[@]}" clean
		emake BOARD="${target}" "${EC_OPTS[@]}" tests
	done
}

src_install() {
	local target
	for target in "${EC_BOARDS[@]}"; do
		insinto /firmware/chromeos-fpmcu-unittests/"${target}"
		doins build/"${target}"/*.bin
	done
}
