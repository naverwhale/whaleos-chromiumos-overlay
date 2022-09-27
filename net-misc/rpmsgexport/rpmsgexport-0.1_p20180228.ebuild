# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-sanitizers

DESCRIPTION="Remoteproc endpoint creation utility"
HOMEPAGE="https://github.com/andersson/rpmsgexport"
GIT_SHA1="324d88d668f36c6a5e6a9c2003a050b8a5a3cd60"
SRC_URI="https://github.com/andersson/rpmsgexport/archive/${GIT_SHA1}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="asan"

S="${WORKDIR}/${PN}-${GIT_SHA1}"

src_configure() {
	sanitizers-setup-env

	# TODO(ejcaruso): send PR to respect CFLAGS/LDFLAGS
	sed -i \
		-e '/^prefix/s:=.*:=/usr:' -e '/^LDFLAGS/d' -e '/^CFLAGS/d' \
		Makefile || die
}
