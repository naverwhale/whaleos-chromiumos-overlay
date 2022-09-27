# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mesa/mesa-7.9.ebuild,v 1.3 2010/12/05 17:19:14 arfrever Exp $

EAPI="6"

CROS_WORKON_PROJECT="chromiumos/third_party/mesa"
CROS_WORKON_LOCALNAME="mesa-amd"
CROS_WORKON_EGIT_BRANCH="chromeos-amd"

inherit base meson multilib-minimal flag-o-matic toolchain-funcs cros-workon arc-build

DESCRIPTION="The Mesa 3D Graphics Library"
HOMEPAGE="http://mesa3d.org/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~*"

VIDEO_CARDS="intel amdgpu radeon freedreno llvmpipe"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS}
	android-container-pi -android_vulkan_compute_0 cheets debug
	vulkan cheets_user cheets_user_64"

# Only allow one vulkan driver as they all write vulkan.cheets.so.
REQUIRED_USE="
	android_vulkan_compute_0? ( vulkan )
	vulkan? ( || ( video_cards_amdgpu video_cards_intel ) )
"

DEPEND="
		>=x11-libs/arc-libdrm-2.4.82[${MULTILIB_USEDEP}]
		sys-devel/arc-llvm:=[${MULTILIB_USEDEP}]
		dev-libs/arc-libelf[${MULTILIB_USEDEP}]
"

RDEPEND="${DEPEND} !media-libs/arc-mesa"

driver_list() {
	local drivers="$(sort -u <<< "${1// /$'\n'}")"
	echo "${drivers//$'\n'/,}"
}

src_configure() {
	cros_optimize_package_for_speed
	arc-build-select-clang
	multilib-minimal_src_configure
}

multilib_src_configure() {
	tc-getPROG PKG_CONFIG pkg-config

	# Intel code
	dri_driver_enable video_cards_intel i965

	gallium_enable video_cards_llvmpipe swrast

	# ATI code
	gallium_enable video_cards_radeon r300 r600
	gallium_enable video_cards_amdgpu radeonsi

	# Freedreno code
	gallium_enable video_cards_freedreno freedreno

	if use vulkan; then
		vulkan_enable video_cards_amdgpu amd
		vulkan_enable video_cards_intel intel
	fi

	# Use llvm-config coming from ARC++ build.
	export LLVM_CONFIG="${ARC_SYSROOT:?}/build/bin/llvm-config-host"

	# The AOSP build system defines the Make variable
	# PLATFORM_SDK_VERSION, and Mesa's Android.mk files use it to
	# define the macro ANDROID_API_LEVEL. Arc emulates that here.
	CPPFLAGS+=" -DANDROID_API_LEVEL=${ARC_PLATFORM_SDK_VERSION:?}"

	arc-build-create-cross-file

	emesonargs+=(
		--prefix="${ARC_PREFIX}/vendor"
		--sysconfdir="/system/vendor/etc"
		-Ddri-search-path="/system/$(get_libdir)/dri:/system/vendor/$(get_libdir)/dri"
		-Dgallium-va=false
		-Dgallium-vdpau=false
		-Dgallium-xvmc=false
		-Dgallium-omx=disabled
		-Dgallum-xa=false
		-Dasm=false
		-Dglx=disabled
		-Ddri3=false
		-Dgles-lib-suffix=_mesa
		-Degl-lib-suffix=_mesa
		-Dllvm=true
		-Dplatforms=android
		-Degl=true
		-Dgbm=false
		-Dgles1=true
		-Dgles2=true
		-Dshared-glapi=true
		-Ddri-drivers=$(driver_list "${DRI_DRIVERS[*]}")
		-Dgallium-drivers=$(driver_list "${GALLIUM_DRIVERS[*]}")
		-Dvulkan-drivers=$(driver_list "${VULKAN_DRIVERS[*]}")
		--buildtype $(usex debug debug release)
		--cross-file="${ARC_CROSS_FILE}"
		-Dplatform-sdk-version="${ARC_PLATFORM_SDK_VERSION:?}"
	)

	meson_src_configure
}

# The meson eclass exports src_compile but not multilib_src_compile. src_compile
# gets overridden by multilib-minimal
multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	exeinto "${ARC_PREFIX}/vendor/$(get_libdir)"
	newexe "${BUILD_DIR}/src/mapi/shared-glapi/libglapi.so.0" libglapi.so.0

	exeinto "${ARC_PREFIX}/vendor/$(get_libdir)/egl"
	newexe "${BUILD_DIR}/src/egl/libEGL_mesa.so" libEGL_mesa.so
	newexe "${BUILD_DIR}/src/mapi/es1api/libGLESv1_CM_mesa.so" libGLESv1_CM_mesa.so
	newexe "${BUILD_DIR}/src/mapi/es2api/libGLESv2_mesa.so" libGLESv2_mesa.so

	exeinto "${ARC_PREFIX}/vendor/$(get_libdir)/dri"
	if use video_cards_intel; then
		newexe "${BUILD_DIR}/src/mesa/drivers/dri/libmesa_dri_drivers.so" i965_dri.so
	fi
	if use video_cards_llvmpipe; then
		newexe "${BUILD_DIR}/src/gallium/targets/dri/libgallium_dri.so" kms_swrast_dri.so
	fi
	if use video_cards_amdgpu; then
		newexe "${BUILD_DIR}/src/gallium/targets/dri/libgallium_dri.so" radeonsi_dri.so
	fi

	if use vulkan; then
		exeinto "${ARC_PREFIX}/vendor/$(get_libdir)/hw"
		if use video_cards_amdgpu; then
			newexe "${BUILD_DIR}/src/amd/vulkan/libvulkan_radeon.so" vulkan.cheets.so
		fi
		if use video_cards_intel; then
			newexe "${BUILD_DIR}/src/intel/vulkan/libvulkan_intel.so" vulkan.cheets.so
		fi
	fi
}

multilib_src_install_all() {
	# For documentation on the feature set represented by each XML file
	# installed into /vendor/etc/permissions, see
	# <https://developer.android.com/reference/android/content/pm/PackageManager.html>.
	# For example XML files for each feature, see
	# <https://android.googlesource.com/platform/frameworks/native/+/master/data/etc>.

	# Install init files to advertise supported API versions.
	insinto "${ARC_PREFIX}/vendor/etc/init"
	doins "${FILESDIR}/init.gpu.rc"

	# Install vulkan related files.
	if use vulkan; then
		einfo "Using android vulkan."
		insinto "${ARC_PREFIX}/vendor/etc/init"
		doins "${FILESDIR}/vulkan.rc"

		insinto "${ARC_PREFIX}/vendor/etc/permissions"
		doins "${FILESDIR}/android.hardware.vulkan.version-1_0_3.xml"
		if use video_cards_intel; then
			doins "${FILESDIR}/android.hardware.vulkan.level-1.xml"
		else
			doins "${FILESDIR}/android.hardware.vulkan.level-0.xml"
		fi
	fi

	if use android_vulkan_compute_0; then
		einfo "Using android vulkan_compute_0."
		insinto "${ARC_PREFIX}/vendor/etc/permissions"
		doins "${FILESDIR}/android.hardware.vulkan.compute-0.xml"
	fi

	# Install permission file to declare opengles aep support.
	einfo "Using android aep."
	insinto "${ARC_PREFIX}/vendor/etc/permissions"
	doins "${FILESDIR}/android.hardware.opengles.aep.xml"

	# Install the dri header for arc-cros-gralloc
	insinto "${ARC_PREFIX}/vendor/include/"
	doins -r "${S}/include/GL/"
}

# $1 - VIDEO_CARDS flag (check skipped for "--")
# other args - names of DRI drivers to enable
dri_driver_enable() {
	if [[ $1 == -- ]] || use "$1"; then
		shift
		DRI_DRIVERS+=("$@")
	fi
}

gallium_enable() {
	if [[ $1 == -- ]] || use "$1"; then
		shift
		GALLIUM_DRIVERS+=("$@")
	fi
}

vulkan_enable() {
	if [[ $1 == -- ]] || use "$1"; then
		shift
		VULKAN_DRIVERS+=("$@")
	fi
}
