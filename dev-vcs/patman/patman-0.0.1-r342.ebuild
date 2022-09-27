# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="ff8cb34d79384524ed81027f7d07a31f7405c27d"
CROS_WORKON_TREE="3429c1a71068b0c1e875e3a0d6aea14f8b4564a5"
CROS_WORKON_PROJECT="chromiumos/third_party/u-boot"
CROS_WORKON_LOCALNAME="u-boot/files"
CROS_WORKON_SUBTREE="tools/patman"

PYTHON_COMPAT=( python3_6 )

inherit cros-workon distutils-r1

DESCRIPTION="Patman tool (from U-Boot) for sending patches upstream"
HOMEPAGE="https://www.denx.de/wiki/U-Boot"

LICENSE="GPL-2"
SLOT="0/0"
KEYWORDS="*"
IUSE=""

BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND=""

src_prepare() {
	cd tools/patman
	distutils-r1_src_prepare
}

src_compile() {
	cd tools/patman
	distutils-r1_src_compile
}

src_install() {
	cd tools/patman
	distutils-r1_src_install
}
