# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="ff8cb34d79384524ed81027f7d07a31f7405c27d"
CROS_WORKON_TREE="b9d094a27545777931d3af534417c065aa9d9985"
CROS_WORKON_PROJECT="chromiumos/third_party/u-boot"
CROS_WORKON_LOCALNAME="u-boot/files"
CROS_WORKON_SUBTREE="tools/dtoc"

PYTHON_COMPAT=( python3_6 python3_7 python3_8 )

inherit cros-workon distutils-r1

DESCRIPTION="Dtoc tool (from U-Boot) for converting devicetree files to C"
HOMEPAGE="https://www.denx.de/wiki/U-Boot"

LICENSE="GPL-2"
SLOT="0/0"
KEYWORDS="*"
IUSE=""

BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="dev-vcs/patman"

src_unpack() {
	cros-workon_src_unpack

	S+=/tools/dtoc
}
