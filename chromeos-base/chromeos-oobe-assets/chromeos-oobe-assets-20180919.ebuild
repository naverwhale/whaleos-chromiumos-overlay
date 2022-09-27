# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="OOBE videos for Chrome OS"

SRC_URI="gs://chromeos-localmirror/distfiles/${PN}-default-${PV}.tar.gz"
S=${WORKDIR}

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

src_install() {
	insinto /usr/share/chromeos-assets/oobe_videos
	doins -r *
}
