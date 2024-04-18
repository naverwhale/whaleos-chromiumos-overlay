# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="ALSA ucm configuration files"
HOMEPAGE="https://www.alsa-project.org"
SRC_URI="https://www.alsa-project.org/files/pub/lib/${P}.tar.bz2"
LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="ucm2"

PATCHES=(
	"${FILESDIR}/0001-enable-V1-configurations.patch"
)

src_install() {
	insinto /usr/share/alsa/ucm2
	if use ucm2; then
		# Install all UCM2 files
		# Any matching /ucm2 configuration will be used
		# first if found, then fall back to UCM1 config
		# in ucm/ directory
		doins -r ucm2/*
	else
		# Install the toplevel file included from alsa-lib.
		doins ucm2/ucm.conf
		# generic.conf needed after alsa-ucm-conf ~1.2.3
		insinto /usr/share/alsa/ucm2/lib
		doins ucm2/lib/generic.conf
	fi
}
