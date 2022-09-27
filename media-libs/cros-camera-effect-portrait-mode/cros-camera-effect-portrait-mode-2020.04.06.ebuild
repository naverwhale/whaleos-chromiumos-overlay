# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Chrome OS camera portrait processor library"
# Version 2020.04.06: built from cl/304948948
SRC_URI="
	amd64? ( gs://chromeos-localmirror/distfiles/portrait-processor-lib-x86_64-${PV}.tbz2 )
	arm? ( gs://chromeos-localmirror/distfiles/portrait-processor-lib-armv7-${PV}.tbz2 )
	"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}"

src_install() {
	dolib.so *.so

	insinto /usr/include/cros-camera
	doins *.h
}
