# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="ca7b4b66c18c97e1d7e21b36a9c76239ea0530ef"
CROS_WORKON_TREE="3df4e9ea258213e789b984b837eac63585d8bb8e"
PYTHON_COMPAT=( python3_{6..8} )

CROS_WORKON_PROJECT="chromiumos/platform/usi-test"
CROS_WORKON_LOCALNAME="platform/usi-test"

inherit cros-workon distutils-r1

DESCRIPTION="Universal Stylus Initiative (USI) Certification Tool"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/usi-test/"
SRC_URI=""

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="-"

RDEPEND="~dev-python/hid-tools-0.2[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}"
