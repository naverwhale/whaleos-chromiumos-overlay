# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

# This is a sample DLC used for testing new features in DLC. It does not really
# build anything, it just creates a DLC image with random content.

EAPI="7"

inherit dlc dlc-prebuilt

DESCRIPTION="A prebuilt sample DLC"
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
