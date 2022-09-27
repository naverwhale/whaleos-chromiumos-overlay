# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="d68b83ccc4a645edeeeeaba39e8fe4e079a01aa2"
CROS_WORKON_TREE="5cc9a8b99ac89b6694f77a27a11613fe1a430581"
CROS_WORKON_PROJECT="chromiumos/platform/btsocket"
CROS_WORKON_LOCALNAME="../platform/btsocket"

PYTHON_COMPAT=( python2_7 python{3_6,3_7} )

inherit cros-sanitizers cros-workon distutils-r1

DESCRIPTION="Bluetooth Socket support module"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/btsocket/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND=""

src_configure() {
	sanitizers-setup-env
	default
}
