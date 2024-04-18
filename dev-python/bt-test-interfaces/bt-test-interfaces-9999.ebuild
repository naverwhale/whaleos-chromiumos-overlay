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
CROS_WORKON_SUBTREE=(
	"pandora/interfaces/pandora_experimental pandora/interfaces/python"
	"pandora/interfaces/pandora_experimental pandora/interfaces/python"
)
CROS_WORKON_EGIT_BRANCH=("main" "upstream/main")
CROS_WORKON_OPTIONAL_CHECKOUT=(
	"use !floss_upstream"
	"use floss_upstream"
)

inherit cros-workon distutils-r1

STABLE_PV=0.0.4
S=${WORKDIR}/${PN}-${STABLE_PV}

DESCRIPTION="AOSP bluetooth test interfaces"
HOMEPAGE="https://github.com/google/bt-test-interfaces"
SRC_URI="
	https://github.com/google/${PN}/archive/v${STABLE_PV}.tar.gz
	-> github.com-google-${PN}-v${STABLE_PV}.tar.gz
"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="~*"
IUSE="floss_upstream"

BDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/grpcio-tools[${PYTHON_USEDEP}]
"

RDEPEND="
	dev-python/grpcio[${PYTHON_USEDEP}]
	dev-python/protobuf-python[${PYTHON_USEDEP}]
"

src_unpack() {
	# This call should be placed before the default to prevent the
	# stable files from being removed.
	cros-workon_src_unpack

	# Re-mapping the experimental part to work dir.
	mv "${S}"/pandora/interfaces/pandora_experimental "${S}"/pandora_experimental/ || die
	mv "${S}"/pandora/interfaces/python "${S}"/python/ || die
	rm -rf "${S}"/pandora || die

	default

	cp "${FILESDIR}"/setup.py "${S}" || die
}

python_compile() {
	"${EPYTHON}" -m grpc_tools.protoc \
		-I"${S}" \
		--plugin=protoc-gen-grpc="${S}"/python/_build/protoc-gen-custom_grpc \
		--python_out="${S}"/python \
		--grpc_out="${S}"/python \
		"${S}"/pandora/* "${S}"/pandora_experimental/* || die
}
