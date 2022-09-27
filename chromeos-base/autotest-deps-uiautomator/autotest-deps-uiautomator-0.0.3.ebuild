# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit autotest-external-dep

# The autotest-external-dep package name.
PACKAGE="uiautomator"

DESCRIPTION="Ebuild that installs cheets autotest-dep package into dep directory"
HOMEPAGE="https://github.com/xiaocong/uiautomator"
GIT_HASH="57ba9333186cc2c748fce8596dd31593a28019a9"
SRC_URI="https://github.com/xiaocong/uiautomator/archive/${GIT_HASH}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

# Autotest enabled by default.
IUSE="+autotest"

AUTOTEST_DEPS_LIST="${PACKAGE}"
AUTOTEST_CONFIG_LIST=
AUTOTEST_PROFILERS_LIST=

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

S=${WORKDIR}

src_unpack() {
	default
	cd "${WORKDIR}"/${PN}-*
	S=${PWD}
}

src_install() {
	autotest-external-dep_src_install
	dosym "${PACKAGE}-${GIT_HASH}/${PACKAGE}" "${AUTOTEST_BASE}/client/deps/${PACKAGE}/${PACKAGE}"
}
