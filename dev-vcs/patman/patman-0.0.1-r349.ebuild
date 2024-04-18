# Copyright 2012 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="625596565e774b62d33e2d27b8ed2bb198f6470b"
CROS_WORKON_TREE="760772f486fed9d0ad0241246a24660ca1dca439"
CROS_WORKON_PROJECT="chromiumos/third_party/u-boot"
CROS_WORKON_LOCALNAME="u-boot/files"
CROS_WORKON_SUBTREE="tools/patman"
CROS_WORKON_EGIT_BRANCH="chromeos-v2023.10-next"

PYTHON_COMPAT=( python3_{6..11} )

inherit cros-workon distutils-r1

DESCRIPTION="Patman tool (from U-Boot) for sending patches upstream"
HOMEPAGE="https://www.denx.de/wiki/U-Boot"

LICENSE="GPL-2"
SLOT="0/0"
KEYWORDS="*"
IUSE=""

BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="dev-libs/u_boot_pylib[${PYTHON_USEDEP}]"

src_unpack() {
	cros-workon_src_unpack

	S+=/tools/patman
}
