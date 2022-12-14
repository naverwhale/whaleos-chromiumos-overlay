# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit autotools-multilib flag-o-matic multilib toolchain-funcs

INFINALITY_PATCH="03-infinality-2.6.2-2015.11.28.patch"

DESCRIPTION="A high-quality and portable font engine"
HOMEPAGE="http://www.freetype.org/"
SRC_URI="mirror://sourceforge/freetype/${P/_/}.tar.bz2
	mirror://nongnu/freetype/${P/_/}.tar.bz2
	utils?	( mirror://sourceforge/freetype/ft2demos-${PV}.tar.bz2
		mirror://nongnu/freetype/ft2demos-${PV}.tar.bz2 )
	doc?	( mirror://sourceforge/freetype/${PN}-doc-${PV}.tar.bz2
		mirror://nongnu/freetype/${PN}-doc-${PV}.tar.bz2 )
	infinality? ( https://dev.gentoo.org/~polynomial-c/${INFINALITY_PATCH}.xz )"

LICENSE="|| ( FTL GPL-2+ )"
SLOT="2"
KEYWORDS="*"
IUSE="X +adobe-cff bindist bzip2 +cleartype_hinting debug doc fontforge harfbuzz
	infinality png static-libs utils"
RESTRICT="!bindist? ( bindist )" # bug 541408

CDEPEND=">=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}]
	bzip2? ( >=app-arch/bzip2-1.0.6-r4[${MULTILIB_USEDEP}] )
	harfbuzz? ( >=media-libs/harfbuzz-0.9.19[truetype,${MULTILIB_USEDEP}] )
	png? ( >=media-libs/libpng-1.2.51:=[${MULTILIB_USEDEP}] )
	utils? (
		X? (
			>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]
			>=x11-libs/libXau-1.0.7-r1[${MULTILIB_USEDEP}]
			>=x11-libs/libXdmcp-1.1.1-r1[${MULTILIB_USEDEP}]
		)
	)"
DEPEND="${CDEPEND}
	virtual/pkgconfig"
RDEPEND="${CDEPEND}
	abi_x86_32? ( utils? ( !app-emulation/emul-linux-x86-xlibs[-abi_x86_32(-)] ) )"
PDEPEND="infinality? ( media-libs/fontconfig-infinality )"

src_prepare() {
	enable_option() {
		sed -i -e "/#define $1/ { s:/\* ::; s: \*/:: }" \
			include/${PN}/config/ftoption.h \
			|| die "unable to enable option $1"
	}

	disable_option() {
		sed -i -e "/#define $1/ { s:^:/* :; s:$: */: }" \
			include/${PN}/config/ftoption.h \
			|| die "unable to disable option $1"
	}

	disable_module() {
		sed -r -i -e "/^(FONT|AUX|HINTING|RASTER)_MODULES \+= $1/ s/^/#/" \
			modules.cfg || die "unable to disable module $1"
	}

	epatch "${FILESDIR}"/${PN}-2.9-bd9400b.patch
	epatch "${FILESDIR}"/${PN}-2.9-libtool.patch
	epatch "${FILESDIR}"/${PN}-2.4.11-sizeof-types.patch # 459966

	# Enable stem-darkening for CFF font
	# TODO(jshin): Evaluate the impact of disabling stem-darkening.
	epatch "${FILESDIR}"/${PN}-2.6.2-enable-cff-stem-darkening.patch

	epatch "${FILESDIR}"/${PN}-2.9-pngshim-bitmap-overflow.patch

	# Will be the new default for >=freetype-2.7.0

	if use infinality && use cleartype_hinting; then
		enable_option "TT_CONFIG_OPTION_SUBPIXEL_HINTING  ( 1 | 2 )"
	elif use infinality; then
		enable_option "TT_CONFIG_OPTION_SUBPIXEL_HINTING  1"
	elif use cleartype_hinting; then
		enable_option "TT_CONFIG_OPTION_SUBPIXEL_HINTING  2"
	fi

	# TODO(jshin): Consider disabling SUBPIXEL_RENDERING and using
	# Harmony (new default in 2.8.1 when FT_CONFIG_OPTION_SUBPIXEL_RENDERING
	# is undefined), instead. See
	# https://bugs.chromium.org/p/chromium/issues/detail?id=654563#c3 .
	# Coordinate with Chromium on Linux.
	if ! use bindist; then
		# See http://freetype.org/patents.html
		# ClearType is covered by several Microsoft patents in the US
		enable_option FT_CONFIG_OPTION_SUBPIXEL_RENDERING
	fi

	disable_option "FT_CONFIG_OPTION_MAC_FONTS"
	disable_option "TT_CONFIG_OPTION_BDF"

	if ! use adobe-cff; then
		enable_option CFF_CONFIG_OPTION_OLD_ENGINE
	fi

	if use debug; then
		enable_option FT_DEBUG_LEVEL_TRACE
		enable_option FT_DEBUG_MEMORY
	fi

	disable_module pcr
	disable_module winfonts
	disable_module pcf
	disable_module bdf
	disable_module lzw
	# TODO(jshin): Check if ghostscript needs type42. (crbug.com/784767)
	# disable_module type42

	if ! use bzip2; then
		disable_module bzip2
	fi


	if use utils; then
		cd "${WORKDIR}/ft2demos-${PV}" || die
		# Disable tests needing X11 when USE="-X". (bug #177597)
		if ! use X; then
			sed -i -e "/EXES\ +=\ ftdiff/ s:^:#:" Makefile || die
		fi
		cd "${S}" || die
	fi

	# we need non-/bin/sh to run configure
	if [[ -n ${CONFIG_SHELL} ]] ; then
		sed -i -e "1s:^#![[:space:]]*/bin/sh:#!$CONFIG_SHELL:" \
			"${S}"/builds/unix/configure || die
	fi

	autotools-utils_src_prepare
}

multilib_src_configure() {
	append-flags -fno-strict-aliasing
	type -P gmake &> /dev/null && export GNUMAKE=gmake

	local myeconfargs=(
		--enable-biarch-config
		$(use_with bzip2)
		$(use_with harfbuzz)
		$(use_with png)

		# avoid using libpng-config
		LIBPNG_CFLAGS="$($(tc-getPKG_CONFIG) --cflags libpng)"
		LIBPNG_LDFLAGS="$($(tc-getPKG_CONFIG) --libs libpng)"
	)

	autotools-utils_src_configure
}

multilib_src_compile() {
	default

	if multilib_is_native_abi && use utils; then
		einfo "Building utils"
		# fix for Prefix, bug #339334
		emake \
			X11_PATH="${EPREFIX}/usr/$(get_libdir)" \
			FT2DEMOS=1 TOP_DIR_2="${WORKDIR}/ft2demos-${PV}"
	fi
}

multilib_src_install() {
	default

	if multilib_is_native_abi && use utils; then
		einfo "Installing utils"
		rm "${WORKDIR}"/ft2demos-${PV}/bin/README || die
		local ft2demo
		for ft2demo in ../ft2demos-${PV}/bin/*; do
			./libtool --mode=install $(type -P install) -m 755 "$ft2demo" \
				"${ED}"/usr/bin || die
		done
	fi
}

multilib_src_install_all() {
	if use fontforge; then
		# Probably fontforge needs less but this way makes things simplier...
		einfo "Installing internal headers required for fontforge"
		local header
		find src/truetype include/freetype/internal -name '*.h' | \
		while read header; do
			mkdir -p "${ED}/usr/include/freetype2/internal4fontforge/$(dirname ${header})" || die
			cp ${header} "${ED}/usr/include/freetype2/internal4fontforge/$(dirname ${header})" || die
		done
	fi

	dodoc docs/{CHANGES,CUSTOMIZE,DEBUG,INSTALL.UNIX,*.txt,PROBLEMS,TODO}
	use doc && dohtml -r docs/*

	prune_libtool_files --all
}
