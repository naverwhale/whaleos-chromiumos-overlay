# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="6"

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE='threads(+)'

inherit toolchain-funcs python-any-r1 waf-utils flag-o-matic

DESCRIPTION="OpenGL (ES) 2.0 benchmark"
HOMEPAGE="https://launchpad.net/glmark2"
# Note: the last tarball hosted on launchpad is 2012.12.tar.gz
# More recent versions are Chromium localmirror hosted tarballs created from
# bzr releases of https://code.launchpad.net/~glmark2-dev/glmark2/trunk
#SRC_URI="http://launchpad.net/${PN}/trunk/${PV}/+download/${P}.tar.gz"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${PN}-bzr-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="drm opengles opengl python X"

REQUIRED_USE="|| ( opengl opengles )"

RDEPEND="media-libs/libpng
	opengles? ( virtual/opengles )
	opengl? ( virtual/opengl )
	X? ( x11-libs/libX11 )
	!X? ( media-libs/waffle )
	drm? ( media-libs/mesa[gbm] )
	virtual/jpeg"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	dev-util/pkgconfig"

PATCHES=(
	"${FILESDIR}/0001-native-state-x11-Don-t-terminate-fullscreen-if-EWMH-.patch"
	"${FILESDIR}/0002-Add-data-path-command-line-option.patch"
	"${FILESDIR}/0003-MainLoop-do-before_scene_setup-in-right-context.patch"
	"${FILESDIR}/0004-SceneDesktop-don-t-modify-framebuffer-zero.patch"
	"${FILESDIR}/0005-GLState-change-native-config-type-to-intptr_t.patch"
	"${FILESDIR}/0006-Add-waffle-backend.patch"
	"${FILESDIR}/0007-data-Remove-unused-uniforms-from-shaders.patch"
	"${FILESDIR}/clang-syntax.patch"
	"${FILESDIR}/libpng-1.6.patch"
	"${FILESDIR}/glmark2-libcxx.patch"
	"${FILESDIR}/deprecated-auto-ptr.patch"
	"${FILESDIR}/fix-out-of-bounds-pointer-write.patch"
)

pkg_setup() {
	python-any-r1_pkg_setup
}

src_configure() {
	local myconf=""
	local flavors=()
	# Remove this one after llvm upgrades.
	append-flags -Wno-unknown-warning-option
	append-flags -Wno-tautological-unsigned-zero-compare
	append-flags -std=gnu++11
	if use X; then
		if use opengl; then
			flavors+=(x11-gl)
		fi

		if use opengles; then
			flavors+=(x11-glesv2)
		fi
	else
		flavors+=(waffle)
	fi

	if use drm; then
		if use opengl; then
			flavors+=(drm-gl)
		fi

		if use opengles; then
			flavors+=(drm-glesv2)
		fi
	fi

	if [ ${#flavors[@]} -gt 0 ]; then
		SAVED_IFS=${IFS}
		IFS=","
		myconf+="--with-flavors=${flavors[*]}"
		IFS=${SAVED_IFS}
	fi

	export PKGCONFIG=$(tc-getPKG_CONFIG)
	waf-utils_src_configure ${myconf}
}
