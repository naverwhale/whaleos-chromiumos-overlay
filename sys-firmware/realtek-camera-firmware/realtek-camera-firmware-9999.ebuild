# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

# This ebuild only cares about its own FILESDIR and ebuild file, so it tracks
# the canonical empty project.
CROS_WORKON_PROJECT="chromiumos/infra/build/empty-project"
CROS_WORKON_LOCALNAME="../platform/empty-project"

inherit cros-workon cros-fwupd

DESCRIPTION="Installs Realtek camera firmware files used by fwupd."
HOMEPAGE="http://www.realtek.com"
KEYWORDS="~*"

FILENAMES=(
	"303bef0da8ff6acd8590bfcebdbdbc8e13bfebd63ca81df5bb6796b8b68c45d5-20230724_YHVA-3_RTS5856_OV2740_Chrome_acerR1-15_cache.cab"
)
SRC_URI="${FILENAMES[*]/#/${CROS_FWUPD_URL}/}"
LICENSE="LVFS-Vendor-Agreement-v1"

DEPEND=""
RDEPEND="sys-apps/fwupd"
