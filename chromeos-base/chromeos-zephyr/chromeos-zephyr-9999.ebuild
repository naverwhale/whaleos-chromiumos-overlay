# Copyright 2021 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI=7

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
KEYWORDS="~*"

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
