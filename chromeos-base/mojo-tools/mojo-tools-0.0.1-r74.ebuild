# Copyright 2021 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT="9d6219e2b80e14355ad054fc467b6dcd9a650360"
CROS_WORKON_TREE="8187c8d907815fb55e8843066076477269bbc23c"
CROS_WORKON_PROJECT=("chromiumos/platform/libchrome")
CROS_WORKON_LOCALNAME=("platform/libchrome")
CROS_WORKON_EGIT_BRANCH=("main")
CROS_WORKON_SUBTREE=("mojo/public/tools")
PYTHON_COMPAT=( python3_{6..9} )

inherit cros-workon python-r1

DESCRIPTION="Mojo python tools for binding generating."
HOMEPAGE="https://chromium.googlesource.com/chromium/src/+/HEAD/mojo/public/tools/mojom/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE=""

RDEPEND="${PYTHON_DEPS}
	dev-python/jinja[${PYTHON_USEDEP}]
"
DEPEND="${PYTHON_DEPS}"

src_install() {
	install_python() {
		python_domodule mojo/public/tools/mojom/mojom
		python_domodule mojo/public/tools/bindings/generators
	}
	python_foreach_impl install_python
}
