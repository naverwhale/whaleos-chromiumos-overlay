# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs flag-o-matic

DESCRIPTION="Linux kernel crash utility"
HOMEPAGE="https://crash-utility.github.io/"
SRC_URI="https://github.com/crash-utility/crash/archive/${PV}.tar.gz -> ${P}.tar.gz
	http://mirrors.kernel.org/gnu/gdb/gdb-10.2.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	>=sys-libs/ncurses-6.3:=
	sys-libs/readline:0=
	sys-libs/zlib:=
	"
DEPEND="${RDEPEND}"
BDEPEND=""

GDB_DIR="${WORKDIR}/gdb-10.2"

export CBUILD=${CBUILD:-${CHOST}}
export CTARGET=${CTARGET:-${CHOST}}

PATCHES=(
	"${FILESDIR}/0001-cross_add_configure_option.patch"
	"${FILESDIR}/0002-donnot-extract-gdb-during-do-compile.patch"
	"${FILESDIR}/0003-gdb-10.2-locale-header.patch"
	"${FILESDIR}/0004-make-src-string-const-in-strlcpy.patch"
	"${FILESDIR}/0005-force_define_architecture.patch"
	"${FILESDIR}/0006-get-compiler-version.patch"
	"${FILESDIR}/0007-gdb-libiberty-skip-checking-cc.patch"
	"${FILESDIR}/0008-enable-large-file-support.patch"
	"${FILESDIR}/0009-disable-some-gdb-libs.patch"
)

src_unpack() {
	default
	mv "${GDB_DIR}" "${S}" || die
}

src_prepare() {
	default
	local target_arch

	case ${ARCH} in
		arm64*)         target_arch=ARM64 ;;
		arm*)           target_arch=ARM ;;
		amd64*|x86*)    target_arch=X86_64 ;;
		*) die "Unsupported arch ${ARCH}" ;;
	esac

	sed -i s/FORCE_DEFINE_ARCH/"${target_arch}"/g "${S}"/configure.c || die
}

src_configure() {
	append-lfs-flags
	tc-export PKG_CONFIG CC

	# This is used by gdb's configure.
	export pkg_config_prog_path="${PKG_CONFIG}"
	export GCC_FOR_TARGET="${CC}"

	# Disable texinfo/documentation
	export MAKEINFO=true

	cros_enable_cxx_exceptions
}

src_compile() {
	emake -C "${S}" \
		RPMPKG="${PV}" \
		GDB_TARGET="${CTARGET}" \
		GDB_HOST="${CBUILD}"
}

src_install() {
	emake -C "${S}" \
		RPMPKG="${PV}" \
		GDB_TARGET="${CTARGET}" \
		GDB_HOST="${CBUILD}" \
		DESTDIR="${D}" install
}
