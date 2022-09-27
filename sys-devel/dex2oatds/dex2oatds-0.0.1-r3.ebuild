# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# The tarball contains the static linked dex2oat binary executable. It is
# produced by Android build server and copied from the url below.
# gs://android-build-chromeos/builds/git_nyc-mr1-arc-linux-static_build_tools/4254306/9522bf7036721fd1cb8074f1a457e860a111924dc320d19975d81e6163fcd7f6/dex2oatds
#
# A functionally similar binary can be created from AOSP source tree with
# command below:
#     ART_BUILD_HOST_STATIC=true ART_BUILD_HOST_NDEBUG=true mmma art/dex2oat
# We do not build it from source because of size and complexity of pulling
# down a big portion of AOSP source tree.
#
# For P, the binary was copied from:
# https://android-build.googleplex.com/builds/submitted/5016670/cheets_x86_64-user/latest
# For RVC, the binary is build from rvc-arc-dev art commit
# 337cf0aa8a455479ca0bcb53a484fd9046c06a91 mmma art/

EAPI="5"

DESCRIPTION="Ebuild which pulls in binaries of dex2oatds"
SRC_URI="gs://chromeos-localmirror/distfiles/${P}.tbz2
	gs://chromeos-localmirror/distfiles/${P}-pi.tbz2
	gs://chromeos-localmirror/distfiles/${P}-rvc.tbz2"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

S="${WORKDIR}"

src_install() {
	dobin dex2oatds
	dobin dex2oatds-pi
	dobin dex2oats-rvc
}
