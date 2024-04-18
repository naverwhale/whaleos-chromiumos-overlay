# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson toolchain-funcs

# intel_clc is an executable that is used to compile OpenCL C code to
# SPIR-V during the build of media-libs/mesa-iris. It is needed to build
# code to support Vulkan ray tracing APIs on Intel MTL GPUs.
#
# intel_clc is a part of Mesa, but since it must run on the build machine,
# it was split it into its own package that gets upreved independently."
DESCRIPTION="intel_clc tool used for building OpenCL C to SPIR-V"
HOMEPAGE="https://mesa3d.org/"

MY_PV="${PV/_/-}"
SRC_URI="https://archive.mesa3d.org/mesa-${MY_PV}.tar.xz"

LICENSE="MIT SGI-B-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="debug"

DEPEND="
	dev-libs/libclc
	dev-util/spirv-tools:=
	dev-libs/expat:=
	>=sys-libs/zlib-1.2.8:=
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=sys-devel/llvm-17[spirv-translator(-)]
"

S="${WORKDIR}/mesa-${MY_PV}"

PATCHES=(
	"${FILESDIR}"/CHROMIUM-Revert-clc-llvm-17-requires-opaque-pointers.patch
	"${FILESDIR}"/CHROMIUM-drop-libdrm-dependency.patch
	"${FILESDIR}"/clc-fix-llvm-cmake-features.patch
)

src_configure() {
	tc-export PKG_CONFIG

	local emesonargs=(
		-Dllvm=enabled
		-Dshared-llvm=disabled
		-Dintel-clc=enabled
		-Dstatic-libclc=all

		-Dgallium-drivers=''
		-Dvulkan-drivers=''

		# Set platforms empty to avoid the default "auto" setting. If
		# platforms is empty meson.build will add surfaceless.
		-Dplatforms=''

		-Dglx=disabled
		-Dzstd=disabled

		--buildtype $(usex debug debug plain)
		-Db_ndebug=$(usex debug false true)
	)
	meson_src_configure
}

src_install() {
	dobin "${BUILD_DIR}"/src/intel/compiler/intel_clc
}
