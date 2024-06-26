# Copyright 2019 The ChromiumOS Authors
# This file distributed under the terms of the BSD license.

EAPI="7"

CROS_WORKON_PROJECT="chromiumos/third_party/novatek-tcon-fw-update-tool"
CROS_WORKON_LOCALNAME="novatek-tcon-fw-update-tool"

inherit cros-common.mk cros-workon

DESCRIPTION="Novatek TCON Firmware Updater"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/novatek-tcon-fw-update-tool/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~*"

src_install() {
	dosbin "${OUT}"/nvt-tcon-fw-updater
}
