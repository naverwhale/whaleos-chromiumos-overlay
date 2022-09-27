# Copyright 2019 The Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="DIAG channel diagnostics communication tool"
HOMEPAGE="https://github.com/andersson/diag"
GIT_SHA1="d06e599d197790c9e84ac41a51bf124a69768c4f"
SRC_URI="https://github.com/andersson/diag/archive/${GIT_SHA1}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

DEPEND="
	net-libs/libqrtr:=
	virtual/udev:=
"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${GIT_SHA1}"

src_prepare() {
	default
	eapply "${FILESDIR}/patches/0001-ODL-support-on-Open-Source-Diag-Router.patch"
}

src_compile() {
	emake HAVE_LIBUDEV=1 HAVE_LIBQRTR=1
}

src_install() {
	emake DESTDIR="${D}" prefix="${EPREFIX}/usr" install
}
