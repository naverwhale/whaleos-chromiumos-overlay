# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake  # EAPI >=7

DESCRIPTION="nextpnr -- a portable FPGA place and route tool."
HOMEPAGE="https://github.com/YosysHQ/nextpnr"

GIT_REV="9782a46a9b4edb24cc73ea65f1ad7697ed74ab41"

# 'tests' submodule.
TESTS_GIT_REV="ccc61e5ec7cc04410462ec3196ad467354787afb"

# '3rdparty/fpga-interchange-schema' submodule.
SCHEMA_GIT_REV="6b2973788692be86c4a8b2cff1353e603e5857a3"

SRC_URI="
	https://github.com/YosysHQ/nextpnr/archive/${GIT_REV}.tar.gz -> nextpnr-${GIT_REV}.tar.gz
	https://github.com/YosysHQ/nextpnr-tests/archive/${TESTS_GIT_REV}.tar.gz -> nextpnr-tests-${TESTS_GIT_REV}.tar.gz
"

LICENSE="ISC"
SLOT="0"
KEYWORDS="*"

DEPEND="
	dev-cpp/eigen:3
	dev-libs/boost
	nexus? ( sci-electronics/prjoxide )
"
RDEPEND="${DEPEND}
	sci-electronics/yosys
"

IUSE="+nexus test"

NEXTPNR_ROOT_DIR="${WORKDIR}/nextpnr-${GIT_REV}"
S="${NEXTPNR_ROOT_DIR}"

pkg_pretend() {
	if ! use nexus; then
		die '
			At least one FPGA family have to be chosen for nextpnr to support.
			Currently supported FPGA families are:
			* Lattice Nexus (USE=nexus)
		'
	fi
}

src_unpack() {
	default

	cd "${NEXTPNR_ROOT_DIR}" || die
	mv -T ../nextpnr-tests-* tests || die
}

src_configure() {
	mycmakeargs=(
		"-DARCH=nexus"
		"-DOXIDE_INSTALL_PREFIX=/usr"
		# Version is based on a repository's `git describe --tags --always`.
		"-DCURRENT_GIT_VERSION=${GIT_REV:0:8}"
		# Supported and tested optional arguments.
		"-DBUILD_TESTS=$(usex test)"
	)
	cmake_src_configure
}

src_test() {
	cmake_src_test

	if use nexus; then
		ebegin "Test creating prjoxide example bitstreams"
		if ! "$BUILD_DIR/nextpnr-nexus" --version; then
			die '`nextpnr-nexus` executable not found in `$BUILD_DIR`!'
		fi
		export PATH="$BUILD_DIR:$PATH"

		cd "$T" || die
		cp -r /usr/share/prjoxide/examples prjoxide-examples || die
		for example in blinky_evn blinky_vip; do
			pushd prjoxide-examples/$example
			emake blinky.bit
			popd
		done
		eend
	fi
}
