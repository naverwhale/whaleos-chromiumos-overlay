# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7

XORG_DOC=doc
XORG_EAUTORECONF="yes"
inherit xorg-3

MY_P="xorg-server-${PV}"
SRC_URI="https://www.x.org/releases/individual/xserver/${MY_P}.tar.bz2"
DESCRIPTION="XWayland"
SLOT="0/${PV}"
KEYWORDS="*"
IUSE="kvm_guest minimal"

# This ebuild and source is based on x11-base/xorg-server so conflicts may occur
# depending on USE flags.
RDEPEND="
	!x11-base/xorg-server
	dev-libs/openssl:0=
	>=dev-libs/wayland-1.3.0
	>=media-libs/mesa-10.3.4-r1
	>=x11-libs/libXfont2-2.0.1
	>=x11-libs/libxshmfence-1.1
	>=x11-libs/pixman-0.27.2
	>=x11-misc/xkeyboard-config-2.4.1-r3
	>=x11-apps/xkbcomp-1.2.3"

DEPEND="${RDEPEND}
	>=dev-libs/wayland-protocols-1.1
	>=sys-kernel/linux-headers-4.4-r16
	media-libs/libepoxy
	>=x11-libs/libdrm-2.4.46
	>=x11-libs/libxkbfile-1.0.4
	>=x11-libs/xtrans-1.3.5
	>=x11-misc/xbitmaps-1.0.1
	>=x11-base/xorg-proto-2018.3"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}"/0001-HACK-make-monotonic-detection-always-succeed-on-cros.patch
	"${FILESDIR}"/0001-xwayland-virtwl-with-dmabuf-for-1.20.1.patch
	"${FILESDIR}"/0001-Eliminate-conflict-with-X11-Xlib.h-with-khronos-eglp.patch
	"${FILESDIR}"/0001-xwayland-sysmacros.patch
	"${FILESDIR}"/0001-xwayland-Fall-back-to-gbm_bo_create-if-no-modifiers-.patch
)

src_prepare() {
	default

	# Needed for patches that modify configure.ac
	eautoreconf
}

src_configure() {
	XORG_CONFIGURE_OPTIONS=(
		--enable-xwayland
		--disable-config-hal
		--disable-devel-docs
		--disable-docs
		--disable-linux-acpi
		--disable-xnest
		--disable-xorg
		--disable-xquartz
		--disable-xvfb
		--disable-xwin
		--sysconfdir="${EPREFIX}"/etc/X11
		--localstatedir="${EPREFIX}"/var
		--with-fontrootdir="${EPREFIX}"/usr/share/fonts
		--with-xkb-output="${EPREFIX}"/var/lib/xkb
		--without-dtrace
		--without-fop
		--with-os-vendor=Gentoo
		--with-sha1=libcrypto
		$(use_enable !minimal dri)
		$(use_enable !minimal dri2)
		$(use_enable !minimal glx)
	)

	if use kvm_guest; then
		XORG_CONFIGURE_OPTIONS+=(
			--with-xkb-bin-directory="/opt/google/cros-containers/bin"
		)
	fi

	xorg-3_src_configure
}
