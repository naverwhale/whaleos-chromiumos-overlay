# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python3_{8..11} )

CROS_WORKON_PROJECT=(
	"aosp/platform/packages/modules/Bluetooth"
	"aosp/platform/packages/modules/Bluetooth"
)
CROS_WORKON_LOCALNAME=(
	"../aosp/packages/modules/Bluetooth/local"
	"../aosp/packages/modules/Bluetooth/upstream"
)
CROS_WORKON_SUBTREE=("floss/pandora" "floss/pandora")
CROS_WORKON_EGIT_BRANCH=("main" "upstream/main")
CROS_WORKON_OPTIONAL_CHECKOUT=(
	"use !floss_upstream"
	"use floss_upstream"
)

inherit cros-workon distutils-r1

DESCRIPTION="Pandora gRPC sever for Floss Bluetooth stack"
HOMEPAGE="https://android.googlesource.com/platform/packages/modules/Bluetooth/+/refs/heads/main/floss/pandora"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"
IUSE="floss_upstream"

BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

RDEPEND="
	dev-python/bt-test-interfaces[${PYTHON_USEDEP}]
	dev-python/protobuf-python[${PYTHON_USEDEP}]
	dev-python/pygobject[${PYTHON_USEDEP}]
	dev-python/pydbus[${PYTHON_USEDEP}]
	dev-python/dbus-python[${PYTHON_USEDEP}]
"

src_unpack() {
	cros-workon_src_unpack

	cp "${FILESDIR}/setup.py" "${S}" || die
}
