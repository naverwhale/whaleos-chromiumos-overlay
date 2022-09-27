# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )
inherit distutils-r1

DESCRIPTION="LiteICLink provides small footprint and configurable Inter-Chip
communication cores."
HOMEPAGE="https://github.com/enjoy-digital/liteiclink"

GIT_REV="3d8ecdbcf9f0260292221ff63b0ad3f5e409a955"
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
