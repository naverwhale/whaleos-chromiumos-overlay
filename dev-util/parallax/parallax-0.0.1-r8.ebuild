# Copyright 2022 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="3b52844e3dac529daf905e8dbf020162ed4784c7"
CROS_WORKON_TREE="7c5c7d5765000ed4c1d2cfb60654ac284598bc7f"
CROS_WORKON_LOCALNAME="../platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_SUBTREE="parallax"

PYTHON_COMPAT=( python3_{6..9} )

inherit cros-workon distutils-r1

DESCRIPTION="Parallax: Visual Analysis Framework"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/parallax/"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="*"
IUSE=""

BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND=""

src_unpack() {
	cros-workon_src_unpack
	S+="/parallax"
}
