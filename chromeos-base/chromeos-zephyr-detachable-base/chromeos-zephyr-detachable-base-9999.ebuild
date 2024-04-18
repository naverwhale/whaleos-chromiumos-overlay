# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI=7

CROS_WORKON_USE_VCSID=1
CROS_WORKON_PROJECT=(
	"chromiumos/third_party/zephyr"
	"chromiumos/platform/ec"
)

CROS_WORKON_LOCALNAME=(
	"third_party/zephyr/main"
	"platform/ec"
)

CROS_WORKON_DESTDIR=(
	"${S}/zephyr-base"
	"${S}/modules/ec"
)

inherit cros-workon cros-zephyr-utils

DESCRIPTION="Zephyr based firmware for detachable base"
KEYWORDS="~*"

src_compile() {
	cros-zephyr-compile zephyr-detachable-base
}

src_install() {
	local project

	while read -r _ && read -r project; do
		if [[ -z "${project}" ]]; then
			continue
		fi

		insinto "/firmware/${project}"
		doins "build/${project}"/output/*
	done < <(cros_config_host "get-firmware-build-combinations" zephyr-detachable-base || die)
}
