# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="Prebuilt test DLC"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/dlcservice"

inherit dlc dlc-prebuilt

DESCRIPTION="A prebuilt test DLC"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}"

# Override DLC_SRC_URI_PREFIX needs to change.
# shellcheck disable=SC2154 # Usage of DLC prebuilt variables.
SRC_URI="
	${DLC_SRC_URI_PREFIX}/${DLC_META_ARTIFACT} -> ${DLC_META_ARTIFACT_LOCAL}
"
RESTRICT="mirror"
