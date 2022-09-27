# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} pypy )

inherit distutils-r1

DESCRIPTION="Google Cloud Storage API client library"
HOMEPAGE="https://pypi.python.org/pypi/google-cloud-storage"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

RDEPEND=">=dev-python/google-resumable-media-0.3.1[${PYTHON_USEDEP}]
	>=dev-python/google-cloud-core-1.0.3[${PYTHON_USEDEP}]
	>=dev-python/google-auth-1.2.0[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]"
