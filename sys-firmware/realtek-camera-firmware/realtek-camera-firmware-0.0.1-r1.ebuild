# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

# This ebuild only cares about its own FILESDIR and ebuild file, so it tracks
# the canonical empty project.
CROS_WORKON_COMMIT="d2d95e8af89939f893b1443135497c1f5572aebc"
CROS_WORKON_TREE="776139a53bc86333de8672a51ed7879e75909ac9"
CROS_WORKON_PROJECT="chromiumos/infra/build/empty-project"
CROS_WORKON_LOCALNAME="../platform/empty-project"

inherit cros-workon cros-fwupd

DESCRIPTION="Installs Realtek camera firmware files used by fwupd."
HOMEPAGE="http://www.realtek.com"
KEYWORDS="*"

FILENAMES=(
	"303bef0da8ff6acd8590bfcebdbdbc8e13bfebd63ca81df5bb6796b8b68c45d5-20230724_YHVA-3_RTS5856_OV2740_Chrome_acerR1-15_cache.cab"
)
SRC_URI="${FILENAMES[*]/#/${CROS_FWUPD_URL}/}"
LICENSE="LVFS-Vendor-Agreement-v1"

DEPEND=""
RDEPEND="sys-apps/fwupd"
