# Copyright 2014 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# factory-mini is a subset of the factory software that can
# be used to run utilities like gooftool, hwid, and regcode, which may
# be useful in the CrOS test environment.  For instance, this would
# allow "gooftool probe" to be used to probe hardware components in
# Moblab.
#
# We don't want to install the entire chromeos-factory package in the
# test image, since it is quite large, so this package comprises a
# small ".par" file (/usr/local/factory-mini/factory-mini.par)
# containing the necessary subset of factory Python code, and symlinks
# from /usr/local/bin to that file.

EAPI=7
CROS_WORKON_COMMIT="8cf2a6067856762da7b28150734880f3d2e9f390"
CROS_WORKON_TREE="dc8714f89570a293664fa364c7a9afec68131703"
CROS_WORKON_PROJECT="chromiumos/platform/factory"
CROS_WORKON_LOCALNAME="platform/factory"
PYTHON_COMPAT=( python3_{8..11} )

inherit cros-workon python-any-r1

# TODO(b/155841952): Merge installer and factory-mini.par

# External dependencies (sync with factory.ebuild)
LOCAL_MIRROR_URL="http://commondatastorage.googleapis.com/chromeos-localmirror/"
WEBGL_AQUARIUM_URI="${LOCAL_MIRROR_URL}/distfiles/webgl-aquarium-20221212.tar.bz2"
SRC_URI="${WEBGL_AQUARIUM_URI}"

DESCRIPTION="Subset of factory software to be installed in test images"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE=""

DEPEND="
	virtual/chromeos-bsp-factory:=
	virtual/chromeos-regions:=
"

RDEPEND="chromeos-base/factory-deps"

# shellcheck disable=SC2016
BDEPEND="
	app-arch/makeself
	app-arch/zip
	dev-java/java-config
	dev-lang/closure-compiler-bin
	dev-libs/closure-library
	dev-libs/protobuf
	$(python_gen_any_dep '
		dev-python/jsonrpclib[${PYTHON_USEDEP}]
		dev-python/jsonschema[${PYTHON_USEDEP}]
		dev-python/protobuf-python[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
	')
	sys-devel/gettext
"

python_check_deps() {
	python_has_version -b \
		"dev-python/jsonrpclib[${PYTHON_USEDEP}]" \
		"dev-python/jsonschema[${PYTHON_USEDEP}]" \
		"dev-python/protobuf-python[${PYTHON_USEDEP}]" \
		"dev-python/pyyaml[${PYTHON_USEDEP}]"
}

pkg_setup() {
	cros-workon_pkg_setup
	python_setup
}

src_unpack() {
	cros-workon_src_unpack
	default
}

src_configure() {
	default

	# Export build settings
	export PYTHON="${EPYTHON}"
	export PYTHON_SITEDIR="${ESYSROOT}$(python_get_sitedir)"
	export SRCROOT="${CROS_WORKON_SRCROOT}"
	export FROM_EBUILD=1

	# Export factory toolkit build settings
	export BOARD="${SYSROOT##*/}"
	export TARGET_DIR=/usr/local/factory
	export WEBGL_AQUARIUM_DIR="${WORKDIR}/webgl_aquarium_static"
	export CLOSURE_LIB_DIR="/opt/closure-library"
}

src_compile() {
	emake par MAKE_PAR_ARGS=--mini PAR_NAME=factory-mini.par

	emake toolkit
}

src_install() {
	exeinto /usr/local/factory-mini
	doexe build/par/factory-mini.par

	# Sanity check: make sure we can run gooftool --help with only
	# the -mini.par file.
	build/par/factory-mini.par gooftool --help |
		grep -q "^usage: gooftool" || die

	# Install only symlinks for binaries usable with factory-mini.par.
	"${S}/bin/install_symlinks" \
		--mode mini --target ../factory-mini/factory-mini.par \
		"${D}"/usr/local/bin || die

	exeinto /usr/local/factory-toolkit
	doexe build/install_factory_toolkit.run
}
