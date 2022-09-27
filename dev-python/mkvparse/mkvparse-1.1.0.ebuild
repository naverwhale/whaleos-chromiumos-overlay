# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
PYTHON_COMPAT=( python{2_7,3_3,3_4,3_6} )

inherit distutils-r1

DESCRIPTION="Python library for parsing mkv files"
HOMEPAGE="https://github.com/vi/mkvparse"
SRC_URI="https://github.com/vi/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
