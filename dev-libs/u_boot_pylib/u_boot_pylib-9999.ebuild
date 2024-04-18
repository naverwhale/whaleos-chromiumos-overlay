# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_PROJECT="chromiumos/third_party/u-boot"
CROS_WORKON_LOCALNAME="u-boot/files"
CROS_WORKON_SUBTREE="tools/u_boot_pylib"
CROS_WORKON_EGIT_BRANCH="chromeos-v2023.10-next"

PYTHON_COMPAT=( python3_{6..11} )

inherit cros-workon distutils-r1

DESCRIPTION="U-Boot python library"
HOMEPAGE="https://www.denx.de/wiki/U-Boot"

LICENSE="GPL-2"
SLOT="0/0"
KEYWORDS="~*"
IUSE=""

BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND=""

src_unpack() {
	cros-workon_src_unpack

	S+=/tools/u_boot_pylib
}
