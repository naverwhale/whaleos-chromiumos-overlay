# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mesa/mesa-7.9.ebuild,v 1.3 2010/12/05 17:19:14 arfrever Exp $

EAPI="5"

CROS_WORKON_PROJECT="chromiumos/third_party/mesa-img"
CROS_WORKON_LOCALNAME="mesa-img"
CROS_WORKON_EGIT_BRANCH="mesa-img"
CROS_WORKON_MANUAL_UPREV="1"

EGIT_REPO_URI="git://anongit.freedesktop.org/mesa/mesa"

inherit base autotools multilib-minimal flag-o-matic toolchain-funcs cros-workon arc-build

OPENGL_DIR="xorg-x11"

DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="http://mesa3d.sourceforge.net/"

# Most of the code is MIT/X11.
# ralloc is LGPL-3
# GLES[2]/gl[2]{,ext,platform}.h are SGI-B-2.0
LICENSE="MIT LGPL-3 SGI-B-2.0"
SLOT="0"
KEYWORDS="~*"

INTEL_CARDS="intel"
RADEON_CARDS="amdgpu radeon"
VIDEO_CARDS="${INTEL_CARDS} ${RADEON_CARDS} llvmpipe mach64 mga nouveau powervr r128 savage sis vmware tdfx via freedreno virgl"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS}
	android_aep -android_gles2 -android_gles30
	+android_gles31 -android_gles32 -android_vulkan_compute_0
	cheets +classic debug dri egl -gallium
	-gbm gles1 gles2 -llvm +nptl pic selinux shared-glapi vulkan X xlib-glx
	cheets_user cheets_user_64"

# llvmpipe requires ARC++ _userdebug images, ARC++ _user images can't use it
# (b/33072485, b/28802929).
# Only allow one vulkan driver as they all write vulkan.cheets.so.
REQUIRED_USE="
	^^ ( android_gles2 android_gles30 android_gles31 android_gles32 )
	android_aep? ( !android_gles2 !android_gles30 )
	android_vulkan_compute_0? ( vulkan )
	cheets? (
		vulkan? ( ^^ ( video_cards_amdgpu video_cards_intel video_cards_powervr ) )
		video_cards_amdgpu? ( llvm )
		video_cards_llvmpipe? ( !cheets_user !cheets_user_64 )
	)"

DEPEND="video_cards_powervr? (
		media-libs/arc-img-ddk
		!<media-libs/arc-img-ddk-1.9
	)
	cheets? (
		>=x11-libs/arc-libdrm-2.4.82[${MULTILIB_USEDEP}]
		llvm? ( sys-devel/arc-llvm:=[${MULTILIB_USEDEP}] )
		video_cards_amdgpu? (
			dev-libs/arc-libelf[${MULTILIB_USEDEP}]
		)
	)"

RDEPEND="${DEPEND}"

# It is slow without texrels, if someone wants slow
# mesa without texrels +pic use is worth the shot
QA_EXECSTACK="usr/lib*/opengl/xorg-x11/lib/libGL.so*"
QA_WX_LOAD="usr/lib*/opengl/xorg-x11/lib/libGL.so*"

# Think about: ggi, fbcon, no-X configs

pkg_setup() {
	# workaround toc-issue wrt #386545
	use ppc64 && append-flags -mminimal-toc
}

src_prepare() {
	# workaround for cros-workon not preserving git metadata
	if [[ ${PV} == 9999* && "${CROS_WORKON_INPLACE}" != "1" ]]; then
		echo "#define MESA_GIT_SHA1 \"git-deadbeef\"" > src/git_sha1.h
	fi

	# apply patches
	if [[ ${PV} != 9999* && -n ${SRC_PATCHES} ]]; then
		EPATCH_FORCE="yes" \
		EPATCH_SOURCE="${WORKDIR}/patches" \
		EPATCH_SUFFIX="patch" \
		epatch
	fi
	# FreeBSD 6.* doesn't have posix_memalign().
	if [[ ${CHOST} == *-freebsd6.* ]]; then
		sed -i \
			-e "s/-DHAVE_POSIX_MEMALIGN//" \
			configure.ac || die
	fi

	# Restrict gles version based on USE flag. (See crbug.com/30202361, b/30202371, b/31041422, b:68023287)
	if use android_gles32; then
		einfo "Limiting android to gles32."
		epatch "${FILESDIR}/gles32/0001-limit-gles-version.patch"
	elif use android_gles31; then
		einfo "Limiting android to gles31."
		epatch "${FILESDIR}/gles31/0001-limit-gles-version.patch"
	elif use android_gles30; then
		einfo "Limiting android to gles30."
		epatch "${FILESDIR}/gles30/0001-limit-gles-version.patch"
	elif use android_gles2; then
		einfo "Limiting android to gles2."
		epatch "${FILESDIR}/gles2/0001-limit-gles-version.patch"
	fi

	epatch "${FILESDIR}"/19.0-util-Don-t-block-SIGSYS-for-new-threads.patch
	epatch "${FILESDIR}"/19.0-radv-Use-given-stride-for-images-imported-from-Andro.patch

	epatch "${FILESDIR}"/CHROMIUM-intel-limit-urb-size-for-SKL-KBL-CFL-GT1.patch

	epatch "${FILESDIR}"/FROMLIST-configure.ac-meson.build-Add-optio.patch
	epatch "${FILESDIR}"/CHROMIUM-configure.ac-depend-on-libnativewindow-when-appropri.patch
	epatch "${FILESDIR}"/CHROMIUM-egl-android-plumb-swrast-option.patch
	epatch "${FILESDIR}"/CHROMIUM-egl-android-use-swrast-option-in-droid_load_driver.patch
	epatch "${FILESDIR}"/CHROMIUM-egl-android-fallback-to-software-rendering.patch

	epatch "${FILESDIR}"/CHROMIUM-anv-move-anv_GetMemoryAndroidHardwareBufferANDROID-u.patch
	epatch "${FILESDIR}"/CHROMIUM-remove-unknown-android-extensions.patch
	epatch "${FILESDIR}"/CHROMIUM-disable-unknown-device-extensions.patch
	epatch "${FILESDIR}"/CHROMIUM-disable-VK_KHR_draw_indirect_count.patch

	epatch "${FILESDIR}"/CHROMIUM-HACK-radv-disable-TC-compatible-HTILE-on-Stoney.patch

	epatch "${FILESDIR}"/FROMLIST-egl-fix-KHR_partial_update-without-EXT_buff.patch
	epatch "${FILESDIR}"/FROMLIST-egl-android-require-ANDROID_native_fence_sy.patch
	epatch "${FILESDIR}"/CHROMIUM-Disable-EGL_KHR_partial_update.patch

	epatch "${FILESDIR}"/FROMLIST-glsl-fix-an-incorrect-max_array_access-afte.patch
	epatch "${FILESDIR}"/FROMLIST-glsl-fix-a-binding-points-assignment-for-ss.patch

	epatch "${FILESDIR}"/FROMLIST-glcpp-Hack-to-handle-expressions-in-line-di.patch
	epatch "${FILESDIR}"/UPSTREAM-intel-Add-support-for-Comet-Lake.patch

	epatch "${FILESDIR}"/UPSTREAM-st-mesa-fix-2-crashes-in-st_tgsi_lower_yuv.patch

	epatch "${FILESDIR}"/CHROMIUM-Add-HAL_PIXEL_FORMAT_YCbCr_420_888-in-vk_format.patch
	epatch "${FILESDIR}"/CHROMIUM-Add-HAL_PIXEL_FORMAT_IMPLEMENTATION_DEFINED-in-vk_fo.patch

	epatch "${FILESDIR}"/CHROMIUM-radv-Disable-VK_KHR_create_renderpass2.patch

	# IMG patches
	epatch "${FILESDIR}"/0001-dri-pvr-Introduce-PowerVR-DRI-driver.patch
	epatch "${FILESDIR}"/0003-dri-Add-some-new-DRI-formats-and-fourccs.patch
	epatch "${FILESDIR}"/0005-GL_EXT_sparse_texture-entry-points.patch
	epatch "${FILESDIR}"/0006-Add-support-for-various-GLES-extensions.patch
	epatch "${FILESDIR}"/0011-GL_EXT_shader_pixel_local_storage2-entry-points.patch
	epatch "${FILESDIR}"/0012-GL_IMG_framebuffer_downsample-entry-points.patch
	epatch "${FILESDIR}"/0013-GL_OVR_multiview-entry-points.patch
	epatch "${FILESDIR}"/0014-Add-OVR_multiview_multisampled_render_to_texture.patch
	epatch "${FILESDIR}"/0019-egl-automatically-call-eglReleaseThread-on-thread-te.patch
	epatch "${FILESDIR}"/0040-GL_EXT_clip_control-entry-point.patch
	epatch "${FILESDIR}"/0045-egl-dri2-try-to-bind-old-context-if-bindContext-fail.patch
	epatch "${FILESDIR}"/0047-mapi-gen-always-use-offsets-from-static-data.patch
	epatch "${FILESDIR}"/0601-mesa-img-Android-build-fixups.patch

	base_src_prepare
	eautoreconf
}

src_configure() {
	cros_optimize_package_for_speed

	if use cheets; then
		#
		# cheets-specific overrides
		#

		arc-build-select-clang
	fi

	multilib-minimal_src_configure
}

multilib_src_configure() {
	tc-getPROG PKG_CONFIG pkg-config

	# IMG code
	driver_enable pvr

	#
	# IMG vulkan driver is part of arc-img-ddk
	# nothing to do here
	#

	export LLVM_CONFIG=${SYSROOT}/usr/bin/llvm-config-host
	EGL_PLATFORM="surfaceless"

	if use cheets; then
		#
		# cheets-specific overrides
		#

		MESA_PLATFORM_SDK_VERSION=${ARC_PLATFORM_SDK_VERSION}

		# Use llvm-config coming from ARC++ build.
		export LLVM_CONFIG="${ARC_SYSROOT}/build/bin/llvm-config-host"

		# FIXME(tfiga): It should be possible to make at least some of these be autodetected.
		EXTRA_ARGS="
			--enable-sysfs
			--with-dri-searchpath=/system/$(get_libdir)/dri:/system/vendor/$(get_libdir)/dri
			--sysconfdir=/system/vendor/etc
			--enable-cross_compiling
			--prefix=${ARC_PREFIX}/vendor
		"
		# FIXME(tfiga): Possibly use flag?
		EGL_PLATFORM="android"

		# The AOSP build system defines the Make variable
		# PLATFORM_SDK_VERSION, and Mesa's Android.mk files use it to
		# define the macro ANDROID_API_LEVEL. Arc emulates that here.
		if [[ -n "${ARC_PLATFORM_SDK_VERSION}" ]]; then
			CPPFLAGS+=" -DANDROID_API_LEVEL=${ARC_PLATFORM_SDK_VERSION}"
		fi

		#
		# end of arc-mesa specific overrides
		#
	fi

	if ! use llvm; then
		export LLVM_CONFIG="no"
	fi

	# TODO(drinkcat): We should provide a pkg-config file for this.
	export PVR_CFLAGS="-I${SYSROOT}${ARC_PREFIX}/vendor/include"
	export PVR_LIBS="-L${SYSROOT}${ARC_PREFIX}/vendor/$(get_libdir) -lcutils -llog -lpvr_dri_support "

	ECONF_SOURCE="${S}" \
	econf \
		${EXTRA_ARGS} \
		--disable-option-checking \
		--with-driver=dri \
		--disable-glu \
		--disable-glut \
		--disable-omx-bellagio \
		--disable-va \
		--disable-vdpau \
		--disable-xvmc \
		--disable-asm \
		--without-demos \
		--enable-texture-float \
		--disable-dri3 \
		$(use_enable llvm llvm-shared-libs) \
		$(use_enable X glx) \
		$(use_enable llvm) \
		$(use_enable egl) \
		$(use_enable gbm) \
		$(use_enable gles1) \
		$(use_enable gles2) \
		$(use_enable shared-glapi) \
		$(use_enable gallium) \
		$(use_enable debug) \
		$(use_enable nptl glx-tls) \
		$(use_enable xlib-glx) \
		$(use_enable !xlib-glx dri) \
		--with-dri-drivers=${DRI_DRIVERS} \
		--with-gallium-drivers=${GALLIUM_DRIVERS} \
		--with-vulkan-drivers=${VULKAN_DRIVERS} \
		--with-egl-lib-suffix=_mesa \
		--with-gles-lib-suffix=_mesa \
		--with-platform-sdk-version=${MESA_PLATFORM_SDK_VERSION} \
		--enable-autotools \
		$(use egl && echo "--with-platforms=${EGL_PLATFORM}")
}

multilib_src_install_cheets() {
	exeinto "${ARC_PREFIX}/vendor/$(get_libdir)"
	newexe $(get_libdir)/libglapi.so libglapi.so

	exeinto "${ARC_PREFIX}/vendor/$(get_libdir)/egl"
	newexe $(get_libdir)/libEGL_mesa.so libEGL_mesa.so
	newexe $(get_libdir)/libGLESv1_CM_mesa.so libGLESv1_CM_mesa.so
	newexe $(get_libdir)/libGLESv2_mesa.so libGLESv2_mesa.so

	exeinto "${ARC_PREFIX}/vendor/$(get_libdir)/dri"
	newexe $(get_libdir)/pvr_dri.so pvr_dri.so
}

multilib_src_install() {
	if use cheets; then
		multilib_src_install_cheets
		return
	fi

	base_src_install

	# Remove redundant headers
	# GLU and GLUT
	rm -f "${D}"/usr/include/GL/glu*.h || die "Removing GLU and GLUT headers failed."
	# Glew includes
	rm -f "${D}"/usr/include/GL/{glew,glxew,wglew}.h \
		|| die "Removing glew includes failed."

	# Move libGL and others from /usr/lib to /usr/lib/opengl/blah/lib
	# because user can eselect desired GL provider.
	ebegin "Moving libGL and friends for dynamic switching"
		dodir /usr/$(get_libdir)/opengl/${OPENGL_DIR}/{lib,extensions,include}
		local x
		for x in "${D}"/usr/$(get_libdir)/libGL.{la,a,so*}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f "${x}" "${D}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/lib \
					|| die "Failed to move ${x}"
			fi
		done
		for x in "${D}"/usr/include/GL/{gl.h,glx.h,glext.h,glxext.h}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f "${x}" "${D}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/include \
					|| die "Failed to move ${x}"
			fi
		done
	eend $?

	dodir /usr/$(get_libdir)/dri
	insinto "/usr/$(get_libdir)/dri/"
	insopts -m0755
	# install the gallium drivers we use
	local gallium_drivers_files=( i915_dri.so nouveau_dri.so r300_dri.so r600_dri.so msm_dri.so swrast_dri.so )
	for x in ${gallium_drivers_files[@]}; do
		if [ -f "${S}/$(get_libdir)/gallium/${x}" ]; then
			doins "${S}/$(get_libdir)/gallium/${x}"
		fi
	done

	# install classic drivers we use
	local classic_drivers_files=( i810_dri.so i965_dri.so nouveau_vieux_dri.so radeon_dri.so r200_dri.so )
	for x in ${classic_drivers_files[@]}; do
		if [ -f "${S}/$(get_libdir)/${x}" ]; then
			doins "${S}/$(get_libdir)/${x}"
		fi
	done
}

multilib_src_install_all_cheets() {
	# Set driconf option to enable S3TC hardware decompression
	insinto "${ARC_PREFIX}/vendor/etc/"
	doins "${FILESDIR}"/drirc

	# For documentation on the feature set represented by each XML file
	# installed into /vendor/etc/permissions, see
	# <https://developer.android.com/reference/android/content/pm/PackageManager.html>.
	# For example XML files for each feature, see
	# <https://android.googlesource.com/platform/frameworks/native/+/master/data/etc>.

	# Install init files to advertise supported API versions.
	#
	# IMG supported API is part of arc-img-ddk
	# nothing to do here
	#

	# Install vulkan related files.
	#
	# IMG vulkan driver is part of arc-img-ddk
	# nothing to do here
	#

	# Install permission file to declare opengles aep support.
	if use android_aep; then
		einfo "Using android aep."
		insinto "${ARC_PREFIX}/vendor/etc/permissions"
		doins "${FILESDIR}/android.hardware.opengles.aep.xml"
	fi

	# Install the dri header for arc-cros-gralloc
	insinto "${ARC_PREFIX}/vendor/include/GL"
	doins -r "${S}/include/GL/internal"
}

multilib_src_install_all() {
	if use cheets; then
		multilib_src_install_all_cheets
		return
	fi

	# Set driconf option to enable S3TC hardware decompression
	insinto "/etc/"
	doins "${FILESDIR}"/drirc
}

pkg_postinst() {
	if use cheets; then
		return
	fi

	# Switch to the xorg implementation.
	echo
	eselect opengl set --use-old ${OPENGL_DIR}
}

# $1 - VIDEO_CARDS flag
# other args - names of DRI drivers to enable
driver_enable() {
	case $# in
		# for enabling unconditionally
		1)
			DRI_DRIVERS+=",$1"
			;;
		*)
			if use $1; then
				shift
				for i in $@; do
					DRI_DRIVERS+=",${i}"
				done
			fi
			;;
	esac
}

gallium_enable() {
	case $# in
		# for enabling unconditionally
		1)
			GALLIUM_DRIVERS+=",$1"
			;;
		*)
			if use $1; then
				shift
				for i in $@; do
					GALLIUM_DRIVERS+=",${i}"
				done
			fi
			;;
	esac
}

vulkan_enable() {
	case $# in
		# for enabling unconditionally
		1)
			VULKAN_DRIVERS+=",$1"
			;;
		*)
			if use $1; then
				shift
				for i in $@; do
					VULKAN_DRIVERS+=",${i}"
				done
			fi
			;;
	esac
}
