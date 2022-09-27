# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

# When the time comes to roll to a new version, download the new gn binary at
# https://chrome-infra-packages.appspot.com/p/gn/gn/linux-amd64/+/
# and run `gn --version` to get the right version number for the ebuild.
# Once you do so, push the gn binary to gs://chromeos-localmirror/distfiles
# and be sure to mark it publicly visible:
#  gsutil cp gn gs://chromeos-localmirror/distfiles/gn-<SHA1>.bin
#  gsutil acl set public-read gs://chromeos-localmirror/distfiles/gn-<SHA1>.bin
#
# Then rename the PV of ebuild file to the date (YYYY.MM.DD) of the
# corresponding commit of the upstream since the upstream doesn't have a
# numeric version format currently.
#
# After that, update GN_X64_SHA1 below with the SHA1 of the gn binary.
# Finally, run `ebuild <ebuild file name> manifest` to generate the Manifest
# file.
GN_X64_SHA1="3e43fac03281e2f5e5ae5f27c8e9a6bb45966ea9"

DESCRIPTION="GN (generate ninja) meta-build system"
HOMEPAGE="https://gn.googlesource.com/gn/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/gn-${GN_X64_SHA1}.bin"
RESTRICT="mirror"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="-* amd64"
IUSE=""

# See chromium:386603 for why we download a prebuilt binary instead of
# compiling it ourselves.

S="${WORKDIR}"  # Otherwise emerge fails because $S doesn't exist.

src_install() {
	newbin "${DISTDIR}/${A}" gn
}
