# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )
DISTUTILS_OPTIONAL="1"
inherit multilib toolchain-funcs eutils distutils-r1

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="git://git.kernel.org/pub/scm/utils/dtc/dtc.git"
	inherit git-r3
else
	SRC_URI="https://www.kernel.org/pub/software/utils/${PN}/${P}.tar.xz"
	KEYWORDS="*"
fi

DESCRIPTION="Open Firmware device tree compiler"
HOMEPAGE="https://devicetree.org/ https://git.kernel.org/cgit/utils/dtc/dtc.git/"

LICENSE="GPL-2"
SLOT="0"
IUSE="python static-libs +yaml"

BDEPEND="
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
"
RDEPEND="
	python? ( ${PYTHON_DEPS} )
	yaml? ( dev-libs/libyaml )
"
DEPEND="${RDEPEND}
	python? (
		dev-lang/swig
	)
"

DOCS="
	${S}/Documentation/dt-object-internal.txt
	${S}/Documentation/dts-format.txt
	${S}/Documentation/manual.txt
"

_emake() {
	# valgrind is used only in 'make checkm'
	emake \
		NO_PYTHON=1 \
		NO_VALGRIND=1 \
		NO_YAML=$(usex !yaml 1 0) \
		\
		AR="$(tc-getAR)" \
		CC="$(tc-getCC)" \
		PKG_CONFIG="$(tc-getPKG_CONFIG)" \
		\
		V=1 \
		\
		PREFIX="${EPREFIX}/usr" \
		\
		LIBDIR="\$(PREFIX)/$(get_libdir)" \
		\
		"$@"
}

src_prepare() {
	default

	eapply "${FILESDIR}"/*.patch

	sed -i \
		-e '/^CFLAGS =/s:=:+=:' \
		-e '/^CPPFLAGS =/s:=:+=:' \
		-e 's:-Werror::' \
		-e 's:-g -Os::' \
		Makefile || die

	if use python ; then
		cd pylibfdt || die
		distutils-r1_src_prepare
	fi
	tc-export AR CC PKG_CONFIG
}

src_configure() {
	default

	if use python ; then
		cd pylibfdt || die
		distutils-r1_src_configure
	fi
}

src_compile() {
	_emake

	if use python ; then
		cd pylibfdt || die
		distutils-r1_src_compile
	fi
}

src_test() {
	_emake check
}

src_install() {
	_emake DESTDIR="${D}" install

	use static-libs || find "${ED}" -name '*.a' -delete

	if use python ; then
		cd pylibfdt || die
		distutils-r1_src_install
	fi
}
