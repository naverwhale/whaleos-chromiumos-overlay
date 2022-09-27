# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-sanitizers

DESCRIPTION="QMI over QRTR test program"
HOMEPAGE="https://github.com/andersson/qmi-ping"
GIT_SHA1="36799ff5464a7ee384dcf3ad3a8f1d2b107f062e"
SRC_URI="https://github.com/andersson/qmi-ping/archive/${GIT_SHA1}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="asan"

DEPEND="net-libs/libqrtr"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${GIT_SHA1}"

src_configure() {
	sanitizers-setup-env

	# TODO(ejcaruso): send PR to respect CFLAGS/LDFLAGS
	sed -i \
		-e '/^prefix/s:=.*:=/usr:' -e '/LDFLAGS/s/:=/+=/' -e '/^CFLAGS/d' \
		Makefile || die
}
