# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_PROJECT="chromiumos/third_party/mesa"
CROS_WORKON_LOCALNAME="mesa-radv"
CROS_WORKON_EGIT_BRANCH="chromeos-radv"

inherit flag-o-matic meson cros-workon

DESCRIPTION="The Mesa 3D Graphics Library"
HOMEPAGE="http://mesa3d.org/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~*"

IUSE="debug llvm +zstd"

RDEPEND="
	virtual/libelf
	dev-libs/expat
	x11-libs/libdrm
	zstd? ( app-arch/zstd )
	!media-libs/mesa
	!media-libs/mesa-amd[vulkan]
"

DEPEND="${RDEPEND}
	llvm? ( sys-devel/llvm )
"

BDEPEND="
	virtual/pkgconfig
"

src_configure() {
	cros_optimize_package_for_speed

	if use llvm; then
		export LLVM_CONFIG=${SYSROOT}/usr/lib/llvm/bin/llvm-config-host
	fi

	emesonargs+=(
		-Dvulkan-drivers=amd
		-Dgallium-drivers=
		-Dplatforms=
		-Dshader-cache-default=false
		-Dshared-llvm=false
		$(meson_feature llvm)
		$(meson_feature zstd)
		--buildtype $(usex debug debug release)
	)

	meson_src_configure
}

src_install() {
	meson_src_install

	# use the driconf from mesa-amd
	rm -v -rf "${ED}"/usr/share/drirc.d/00-mesa-defaults.conf
}
