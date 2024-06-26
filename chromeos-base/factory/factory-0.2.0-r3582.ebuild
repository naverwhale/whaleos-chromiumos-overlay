# Copyright 2016 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="8cf2a6067856762da7b28150734880f3d2e9f390"
CROS_WORKON_TREE="dc8714f89570a293664fa364c7a9afec68131703"
CROS_WORKON_PROJECT="chromiumos/platform/factory"
CROS_WORKON_LOCALNAME="platform/factory"
CROS_WORKON_OUTOFTREE_BUILD=1

PYTHON_COMPAT=( python3_{8..11} )

inherit cros-workon python-single-r1 cros-constants cros-factory

# External dependencies
LOCAL_MIRROR_URL=http://commondatastorage.googleapis.com/chromeos-localmirror/
WEBGL_AQUARIUM_URI=${LOCAL_MIRROR_URL}/distfiles/webgl-aquarium-20221212.tar.bz2

DESCRIPTION="Chrome OS Factory Software Platform"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/factory/"
SRC_URI="${WEBGL_AQUARIUM_URI}"
LICENSE="BSD-Google"
KEYWORDS="*"

IUSE="test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# TODO(b/263836581) We will propose to inline virtual packages when calculating
# reverse dependency. We can remove duplicate dependencies, for example
# chromeos-base/factory-board, if the proposal is accepted.
RDEPEND="
	${PYTHON_DEPS}
	chromeos-base/factory-deps
"
DEPEND="
	${PYTHON_DEPS}
	test? ( chromeos-base/factory-deps )
	virtual/chromeos-bsp-factory:=
	|| (
		chromeos-base/factory-board
		chromeos-base/chromeos-factory-board
	)
	chromeos-base/factory-baseboard
	virtual/chromeos-regions:=
"

# shellcheck disable=SC2016
BDEPEND="
	app-arch/makeself
	app-arch/zip
	chromeos-base/vboot_reference
	dev-java/java-config
	dev-lang/closure-compiler-bin
	dev-libs/closure-library
	dev-libs/protobuf
	$(python_gen_cond_dep '
		dev-python/jsonrpclib[${PYTHON_USEDEP}]
		dev-python/jsonschema[${PYTHON_USEDEP}]
		dev-python/protobuf-python[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
	')
	sys-devel/gettext
"

BUILD_DIR="${WORKDIR}/build"

pkg_setup() {
	cros-workon_pkg_setup
	python_setup
}

src_prepare() {
	default
	# Need the lddtree from the chromite dir.
	export PATH="${CHROMITE_BIN_DIR}:${PATH}"
}

src_configure() {
	default

	# Export build settings
	export BOARD="${SYSROOT##*/}"
	export OUTOFTREE_BUILD="${CROS_WORKON_OUTOFTREE_BUILD}"
	export PYTHON="${EPYTHON}"
	export PYTHON_SITEDIR="${ESYSROOT}$(python_get_sitedir)"
	export SRCROOT="${CROS_WORKON_SRCROOT}"
	export TARGET_DIR=/usr/local/factory
	export WEBGL_AQUARIUM_DIR="${WORKDIR}/webgl_aquarium_static"
	export CLOSURE_LIB_DIR="/opt/closure-library"
	export FROM_EBUILD=1

	# Support out-of-tree build.
	export BUILD_DIR="${WORKDIR}/build"

	export BUNDLE_DIR="${WORKDIR}/bundle"
}

src_unpack() {
	cros-workon_src_unpack
	default
}

src_compile() {
	emake bundle
	emake project-toolkits
}

src_test() {
	emake ebuild-test
}

src_install() {
	# The path of bundle is defined in chromite/cbuildbot/commands.py
	local bundle_dest
	bundle_dest="${ED}/usr/local/factory"
	mkdir -p "${bundle_dest}"
	mv "${WORKDIR}/bundle" "${bundle_dest}"

	shopt -s nullglob
	local list_of_toolkits=("${BUILD_DIR}/"*"_install_factory_toolkit.run")
	shopt -u nullglob
	if [[ "${#list_of_toolkits[@]}" -ne 0 ]]; then
		local GZ=pigz
		type pigz >/dev/null 2>&1 || GZ=gzip

		local archive_path="${WORKDIR}/factory_project_toolkits.tar.gz"
		local list_of_toolkit_names=()
		local toolkit
		for toolkit in "${list_of_toolkits[@]}"; do
			list_of_toolkit_names+=( "$(basename "${toolkit}")" )
		done
		tar -I "${GZ}" -cvf "${archive_path}" \
			-C "${BUILD_DIR}" "${list_of_toolkit_names[@]}" || die
		exeinto "${TARGET_DIR}/project_toolkits"
		doexe "${archive_path}"
	fi

	insinto "${CROS_FACTORY_BOARD_RESOURCES_DIR}"
	doins "${BUILD_DIR}/resource/installer.tar"
}
