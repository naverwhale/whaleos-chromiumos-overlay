# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="ed9a04037053347e4ad2fd779a73ea615fd2e513"
CROS_WORKON_TREE="1de25b0683139e5255fcf749bc31bcb20dbc6533"
CROS_WORKON_PROJECT="chromiumos/third_party/khronos"
CROS_WORKON_LOCALNAME="khronos"

inherit cros-workon

DESCRIPTION="OpenGL|ES headers."
HOMEPAGE="http://www.khronos.org/opengles/2_X/"
SRC_URI=""
LICENSE="SGI-B-2.0"
KEYWORDS="*"
IUSE=""

# libX11 needs to be in RDEPEND because we depend on the header being present
RDEPEND="x11-libs/libX11:="
DEPEND="
	${RDEPEND}
	>=dev-util/opencl-headers-2021.04.29
	>=dev-util/spirv-headers-1.5.4.1
"

src_install() {
	# headers
	insinto /usr/include/EGL
	doins "${S}/include/EGL/egl.h"
	doins "${S}/include/EGL/eglplatform.h"
	doins "${S}/include/EGL/eglext.h"
	insinto /usr/include/KHR
	doins "${S}/include/KHR/khrplatform.h"
	insinto /usr/include/GLES
	doins "${S}/include/GLES/gl.h"
	doins "${S}/include/GLES/glext.h"
	doins "${S}/include/GLES/glplatform.h"
	insinto /usr/include/GLES2
	doins "${S}/include/GLES2/gl2.h"
	doins "${S}/include/GLES2/gl2ext.h"
	doins "${S}/include/GLES2/gl2platform.h"
	insinto /usr/include/GLES3
	doins "${S}/include/GLES3/gl3.h"
	doins "${S}/include/GLES3/gl31.h"
	doins "${S}/include/GLES3/gl32.h"
	doins "${S}/include/GLES3/gl3platform.h"
}
