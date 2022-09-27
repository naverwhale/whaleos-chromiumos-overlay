# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )
DISTUTILS_USE_SETUPTOOLS=rdepend
inherit distutils-r1

DESCRIPTION="LiteScope provides a small footprint and configurable Logic Analyzer core."
HOMEPAGE="https://github.com/enjoy-digital/litescope"

GIT_REV="1243ab3c81fc33ddacb3c15d18b6c63a45e6989e"
SRC_URI="https://github.com/enjoy-digital/${PN}/archive/${GIT_REV}.tar.gz -> ${PN}-${GIT_REV}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	sci-electronics/litex[${PYTHON_USEDEP}]
	sci-electronics/migen[${PYTHON_USEDEP}]
"

S="${WORKDIR}/${PN}-${GIT_REV}"

distutils_enable_tests unittest

src_test() {
	# Requires 'litex_boards' module.
	mv test/{,skipped-}test_examples.py

	distutils-r1_src_test
}
