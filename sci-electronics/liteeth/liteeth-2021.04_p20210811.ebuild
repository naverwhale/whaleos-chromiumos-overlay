# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )
DISTUTILS_USE_SETUPTOOLS=rdepend
inherit distutils-r1

DESCRIPTION="LiteEth provides a small footprint and configurable Ethernet core."
HOMEPAGE="https://github.com/enjoy-digital/liteeth"

GIT_REV="c6c8be703bb5a2351df222a758f9dce0edd5517c"
SRC_URI="https://github.com/enjoy-digital/${PN}/archive/${GIT_REV}.tar.gz -> ${PN}-${GIT_REV}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	sci-electronics/liteiclink[${PYTHON_USEDEP}]
	sci-electronics/litex[${PYTHON_USEDEP}]
	sci-electronics/migen[${PYTHON_USEDEP}]
"

S="${WORKDIR}/${PN}-${GIT_REV}"

distutils_enable_tests unittest
