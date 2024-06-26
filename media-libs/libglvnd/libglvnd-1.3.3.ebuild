# Copyright 2018-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGIT_REPO_URI="https://gitlab.freedesktop.org/glvnd/libglvnd.git"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-r3"
fi

PYTHON_COMPAT=( python3_{8..11} )
VIRTUALX_REQUIRED=manual

inherit ${GIT_ECLASS} meson multilib-minimal python-any-r1 virtualx

DESCRIPTION="The GL Vendor-Neutral Dispatch library"
HOMEPAGE="https://gitlab.freedesktop.org/glvnd/libglvnd"
if [[ ${PV} = 9999* ]]; then
	SRC_URI=""
else
	KEYWORDS="*"
	SRC_URI="https://gitlab.freedesktop.org/glvnd/${PN}/-/archive/v${PV}/${PN}-v${PV}.tar.bz2 -> ${P}.tar.bz2"
	S=${WORKDIR}/${PN}-v${PV}
fi

LICENSE="MIT"
SLOT="0"
IUSE="test X"
RESTRICT="!test? ( test )"

BDEPEND="${PYTHON_DEPS}
	test? ( X? ( ${VIRTUALX_DEPEND} ) )"
RDEPEND="
	!media-libs/mesa[-libglvnd(-)]
	!media-libs/mesa-amd[-libglvnd(-)]
	!media-libs/mesa-freedreno[-libglvnd(-)]
	!media-libs/mesa-img[-libglvnd(-)]
	!media-libs/mesa-iris[-libglvnd(-)]
	!media-libs/mesa-llvmpipe[-libglvnd(-)]
	!media-libs/mesa-panfrost[-libglvnd(-)]
	!media-libs/mesa-reven[-libglvnd(-)]
	X? (
		x11-libs/libX11[${MULTILIB_USEDEP}]
		x11-libs/libXext[${MULTILIB_USEDEP}]
	)"
DEPEND="${RDEPEND}
	X? ( x11-base/xorg-proto )"

src_prepare() {
	default
	sed -i -e "/^PLATFORM_SYMBOLS/a '__gentoo_check_ldflags__'," \
		bin/symbols-check.py || die
}

multilib_src_configure() {
	local emesonargs=(
		$(meson_feature X x11)
		$(meson_feature X glx)
		-Dgles1=false
		-Dheaders=true
		-Dentrypoint-patching=disabled
	)
	use elibc_musl && emesonargs+=( -Dtls=disabled )

	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_test() {
	if use X; then
		virtx meson_src_test
	else
		meson_src_test
	fi
}

multilib_src_install() {
	meson_src_install

	# Remove redundant GLES headers
	rm -f "${D}"/usr/include/{EGL,GLES2,GLES3,KHR}/*.h || die "Removing GLES headers failed."
}
