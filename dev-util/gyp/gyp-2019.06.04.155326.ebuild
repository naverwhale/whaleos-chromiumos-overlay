# Copyright 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PYTHON_COMPAT=( python2_7 python3_{6,7} )
inherit distutils-r1

# To uprev, replace the hash with the desired revision.
# rev="aca1e2c3d346d704adfa60944e6b4dd06f4728be"
# stamp=$(TZ=UTC git show ${revision} --date=format-local:%Y.%m.%d.%H%M%S -s --format=%cd)
# wget https://chromium.googlesource.com/external/gyp/+archive/${rev}.tar.gz
# gsutil cp -a public-read ${rev}.tar.gz gs://chromeos-localmirror/distfiles/gyp-${timestamp}.tar.gz
# Rename the existing .ebuild file to gyp-${timestamp}.ebuild, updating the revision.
# ebuild gyp-${timestamp}.ebuild manifest

DESCRIPTION="GYP, a tool to generates native build files"
HOMEPAGE="https://gyp.gsrc.io/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

S=${WORKDIR}

PATCHES=(
	"${FILESDIR}"/${PN}-2018.02.07.213755-shlex-split-fix.patch
	"${FILESDIR}"/${PN}-2018.02.07.213755-ninja-symlink-fix.patch
	# Sent upstream: https://crrev.com/c/1697943
	"${FILESDIR}"/${PN}-2019.06.04.155326-utf8-python3.patch
)
