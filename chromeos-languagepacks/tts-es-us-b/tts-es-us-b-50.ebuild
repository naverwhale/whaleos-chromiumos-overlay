# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit dlc

DESCRIPTION="tts es-us Language Pack for Chromium OS"

SRC_URI="gs://chromeos-localmirror/distfiles/languagepack-tts-es-us-${PV}.tar.xz"


LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

IUSE="dlc"
REQUIRED_USE="dlc"

DLC_PREALLOC_BLOCKS="3317"
# Enable scaled DLC design. See go/dlc-scaling and b/236008158.
DLC_SCALED=true

# Override S, as we store everything in the root directory of the archive.
S="${WORKDIR}"

src_install() {
	insinto "$(dlc_add_path /)"

	doins voice.zvoice

	dlc_src_install
}
