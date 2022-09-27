# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=7

PYTHON_COMPAT=( python{2_7,3_3,3_4,3_6} pypy )

inherit distutils-r1

DESCRIPTION="Common protobufs used in Google APIs"
HOMEPAGE="https://pypi.python.org/pypi/googleapis-common-protos"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

RDEPEND=""
DEPEND="${RDEPEND}
	dev-python/setuptools"
