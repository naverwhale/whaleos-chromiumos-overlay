# Copyright 2020 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="625596565e774b62d33e2d27b8ed2bb198f6470b"
CROS_WORKON_TREE="7cd38d824a0390240e1b10d2267c6a6083b36c64"
CROS_WORKON_PROJECT="chromiumos/third_party/u-boot"
CROS_WORKON_LOCALNAME="u-boot/files"
CROS_WORKON_SUBTREE="tools/dtoc"
CROS_WORKON_EGIT_BRANCH="chromeos-v2023.10-next"

PYTHON_COMPAT=( python3_{6..11} )

inherit cros-workon distutils-r1

DESCRIPTION="Dtoc tool (from U-Boot) for converting devicetree files to C"
HOMEPAGE="https://www.denx.de/wiki/U-Boot"

LICENSE="GPL-2"
SLOT="0/0"
KEYWORDS="*"
IUSE=""

BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="dev-libs/u_boot_pylib[${PYTHON_USEDEP}]"

src_unpack() {
	cros-workon_src_unpack

	S+=/tools/dtoc
}
