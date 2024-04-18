# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2.

EAPI=7

CROS_WORKON_PROJECT="external/pigweed/pigweed/pigweed"
CROS_WORKON_LOCALNAME="third_party/pigweed"
CROS_WORKON_SUBTREE="pw_tokenizer/py"

PYTHON_COMPAT=( python3_{8..11} )

inherit cros-workon distutils-r1

DESCRIPTION="Pigweed tokenizer"
HOMEPAGE="https://pigweed.dev/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"
IUSE=""

BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_unpack() {
	cros-workon_src_unpack
	S+="/pw_tokenizer/py"

	cat > "${S}/setup.py" <<- EOF || die
		from setuptools import setup
		setup()
	EOF
}
