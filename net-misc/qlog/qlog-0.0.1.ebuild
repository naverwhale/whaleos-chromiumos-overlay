# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="Log collection utility for Quectel modems"
HOMEPAGE="https://github.com/quectel-official/QLog"
GIT_SHA1="60582c4bd130c3598998ab85b77ef6728e96d7f4"
SRC_URI="${HOMEPAGE}/archive/${GIT_SHA1}.tar.gz -> QLog-${GIT_SHA1}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	virtual/libudev:=
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/QLog-${GIT_SHA1}"

src_install() {
	default

	insinto /usr/share/qlog
	doins "${S}"/conf/default.cfg
}
