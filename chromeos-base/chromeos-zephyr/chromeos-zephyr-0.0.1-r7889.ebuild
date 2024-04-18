# Copyright 2021 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI=7

CROS_WORKON_COMMIT=("802895f1ed773f31e46b08e03124b75e75211bd2" "42cf183a4a5f1fcc11c8b1ba579e5babc6d15f2b" "73ea0a4fa12b59410c67c6e7e7504f9356d23dc8" "5c49b1965125b9ac616080f75c8d9bd7bbfcb07c" "6669e41959e4e1c1b24959a1cf3a78f3b0dd9c1e" "24bec3ca536ede086a6932a2f84b290914ad8fde" "3e61925354542ecc7fecaa27be7bc136de55aca3")
CROS_WORKON_TREE=("7536949066b3e46dded2aecad7afcda6f9033c58" "01bcc11fb1670f8481ea3ce8c9626a735ef4a064" "3ee249bc55638bf8dfa89eca1f4918f02e48c512" "e8babfca3b672f6c5f07d2d8bbab3fb354597623" "10c22e1c78d819c6a0561f4efc4adb22b66bba32" "1a3b47c94b22d7d731993498fbca9c248a2183d1" "d145c6a5b65d1accc879042b0754470abb831c21")
CROS_WORKON_USE_VCSID=1
CROS_WORKON_PROJECT=(
	"chromiumos/third_party/zephyr"
	"chromiumos/third_party/zephyr/cmsis"
	"chromiumos/third_party/zephyr/hal_stm32"
	"chromiumos/third_party/zephyr/nanopb"
	"chromiumos/third_party/zephyr/picolibc"
	"external/pigweed/pigweed/pigweed"
	"chromiumos/platform/ec"
)

CROS_WORKON_LOCALNAME=(
	"third_party/zephyr/main"
	"third_party/zephyr/cmsis"
	"third_party/zephyr/hal_stm32"
	"third_party/zephyr/nanopb"
	"third_party/zephyr/picolibc"
	"third_party/pigweed"
	"platform/ec"
)

CROS_WORKON_DESTDIR=(
	"${S}/zephyr-base"
	"${S}/modules/cmsis"
	"${S}/modules/hal_stm32"
	"${S}/modules/nanopb"
	"${S}/modules/picolibc"
	"${S}/modules/pigweed"
	"${S}/modules/ec"
)

inherit cros-workon cros-zephyr-utils

DESCRIPTION="Zephyr based Embedded Controller firmware"
KEYWORDS="*"

src_compile() {
	cros-zephyr-compile zephyr-ec
}

src_install() {
	local firmware_name project
	local root_build_dir="build"

	while read -r firmware_name && read -r project; do
		if [[ -z "${project}" ]]; then
			continue
		fi

		# Do not strip elf files so debug symbols are available
		# in the firmware_from_source.tar.bz2 bundles from builders.
		dostrip -x "/firmware/${firmware_name}"/zephyr.{rw,ro}.elf

		insinto "/firmware/${firmware_name}"
		doins "${root_build_dir}/${project}"/output/*
	done < <(cros_config_host "get-firmware-build-combinations" zephyr-ec || die)
}
