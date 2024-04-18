# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk net-base patchpanel .gn"

PLATFORM_SUBDIR="patchpanel/pp_cli"

inherit cros-workon libchrome platform

DESCRIPTION="CLI to control patchpanel internal state through DBus"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/patchpanel/pp_cli/"
LICENSE="BSD-Google"
KEYWORDS="~*"

COMMON_DEPEND="
	chromeos-base/patchpanel-client:=
"

RDEPEND="
	${COMMON_DEPEND}
"

DEPEND="
	${COMMON_DEPEND}
"
