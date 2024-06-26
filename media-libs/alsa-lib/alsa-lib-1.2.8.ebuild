# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )

inherit autotools multilib multilib-minimal python-single-r1

DESCRIPTION="Advanced Linux Sound Architecture Library"
HOMEPAGE="https://alsa-project.org/"
SRC_URI="https://www.alsa-project.org/files/pub/lib/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="alisp debug doc elibc_uclibc python +thread-safety"

# add ucm2/ucm.conf for UCM1 compatibility
RDEPEND="
	python? ( ${PYTHON_DEPS} )
	media-libs/alsa-ucm-conf
"
DEPEND="${RDEPEND}
	doc? ( >=app-doc/doxygen-1.2.6 )"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

PATCHES=(
	"${FILESDIR}/0001-ucm-add-existence-checks-to-geti-calls.patch"
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	find . -name Makefile.am -exec sed -i -e '/CFLAGS/s:-g -O2::' {} + || die
	# https://bugs.gentoo.org/509886
	if use elibc_uclibc ; then
		# shellcheck disable=SC2016
		sed -i -e 's:oldapi queue_timer:queue_timer:' test/Makefile.am || die
	fi
	# https://bugs.gentoo.org/545950
	# shellcheck disable=SC2016
	sed -i -e '5s:^$:\nAM_CPPFLAGS = -I$(top_srcdir)/include:' test/lsb/Makefile.am || die
	default
	eautoreconf
}

multilib_src_configure() {
	cros_optimize_package_for_speed

	local myeconfargs=(
		--disable-maintainer-mode
		--disable-resmgr
		--enable-aload
		--enable-rawmidi
		--enable-seq
		--enable-shared
		# enable Python only on final ABI
		"$(multilib_native_use_enable python)"
		"$(use_enable alisp)"
		"$(use_enable thread-safety)"
		"$(use_with debug)"
		"$(usex elibc_uclibc --without-versioned '')"
	)

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_compile() {
	emake

	if multilib_is_native_abi && use doc; then
		emake doc
		grep -FZrl "${S}" doc/doxygen/html | \
			xargs -0 sed -i -e "s:${S}::"
	fi
}

multilib_src_install() {
	emake DESTDIR="${D}" install
	if multilib_is_native_abi && use doc; then
		docinto html
		dodoc -r doc/doxygen/html/.
	fi
}

multilib_src_install_all() {
	find "${ED}" -type f \( -name '*.a' -o -name '*.la' \) -delete || die
	dodoc ChangeLog doc/asoundrc.txt NOTES TODO
}
