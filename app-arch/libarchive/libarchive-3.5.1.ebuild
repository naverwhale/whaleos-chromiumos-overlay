# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit libtool multilib-minimal toolchain-funcs

DESCRIPTION="Multi-format archive and compression library"
HOMEPAGE="https://www.libarchive.org/"
SRC_URI="https://www.libarchive.org/downloads/${P}.tar.gz"

LICENSE="BSD BSD-2 BSD-4 public-domain"
SLOT="0/13"
KEYWORDS="*"
IUSE="acl blake2 +bzip2 +e2fsprogs expat +iconv kernel_linux lz4 +lzma lzo nettle static-libs +threads xattr +zlib zstd"

RDEPEND="
	acl? ( virtual/acl[${MULTILIB_USEDEP}] )
	blake2? ( app-crypt/libb2[${MULTILIB_USEDEP}] )
	bzip2? ( app-arch/bzip2[${MULTILIB_USEDEP}] )
	expat? ( dev-libs/expat[${MULTILIB_USEDEP}] )
	!expat? ( dev-libs/libxml2[${MULTILIB_USEDEP}] )
	iconv? ( virtual/libiconv[${MULTILIB_USEDEP}] )
	kernel_linux? (
		xattr? ( sys-apps/attr[${MULTILIB_USEDEP}] )
	)
	dev-libs/openssl:0=[${MULTILIB_USEDEP}]
	lz4? ( >=app-arch/lz4-0_p131:0=[${MULTILIB_USEDEP}] )
	lzma? ( app-arch/xz-utils[threads=,${MULTILIB_USEDEP}] )
	lzo? ( >=dev-libs/lzo-2[${MULTILIB_USEDEP}] )
	nettle? ( dev-libs/nettle:0=[${MULTILIB_USEDEP}] )
	zlib? ( sys-libs/zlib[${MULTILIB_USEDEP}] )
	zstd? ( app-arch/zstd[${MULTILIB_USEDEP}] )"
DEPEND="${RDEPEND}
	kernel_linux? (
		virtual/os-headers
		e2fsprogs? ( sys-fs/e2fsprogs )
	)"

PATCHES=(
	"${FILESDIR}"/${PN}-3.5.0-darwin-strnlen.patch  # drop on next release
	# There was a security vulnerability in libarchive's rar5 support. We don't
	# have a fix yet, but we also don't use it (unlike libarchive's support for
	# other formats). Just disable it.
	# https://bugs.chromium.org/p/chromium/issues/detail?id=1233932
	"${FILESDIR}"/${PN}-3.5.1-disable-rar5.patch
	# https://github.com/libarchive/libarchive/commit/4da892a67a30476798af79586fec79388620756c
	# was committed on 2021-01-10, after 3.5.1 was released on 2020-12-26.
	"${FILESDIR}"/${PN}-3.5.1-7zip-32-bit-size.patch
)

src_prepare() {
	default
	elibtoolize  # is required for Solaris sol2_ld linker fix
}

multilib_src_configure() {
	export ac_cv_header_ext2fs_ext2_fs_h=$(usex e2fsprogs) #354923

	local myconf=(
		$(use_enable acl)
		$(use_enable static-libs static)
		$(use_enable xattr)
		$(use_with blake2 libb2)
		$(use_with bzip2 bz2lib)
		$(use_with expat)
		$(use_with !expat xml2)
		$(use_with iconv)
		$(use_with lz4)
		$(use_with lzma)
		$(use_with lzo lzo2)
		$(use_with nettle)
		$(use_with zlib)
		$(use_with zstd)

		# Windows-specific
		--without-cng
	)
	if multilib_is_native_abi ; then
		myconf+=(
			--enable-bsdcat=$(tc-is-static-only && echo static || echo shared)
			--enable-bsdcpio=$(tc-is-static-only && echo static || echo shared)
			--enable-bsdtar=$(tc-is-static-only && echo static || echo shared)
		)
	else
		myconf+=(
			--disable-bsdcat
			--disable-bsdcpio
			--disable-bsdtar
		)
	fi

	ECONF_SOURCE="${S}" econf "${myconf[@]}"
}

multilib_src_compile() {
	if multilib_is_native_abi ; then
		emake
	else
		emake libarchive.la
	fi
}

src_test() {
	mkdir -p "${T}"/bin || die
	# tests fail when lbzip2[symlink] is used in place of ref bunzip2
	ln -s "${BROOT}/bin/bunzip2" "${T}"/bin || die
	local -x PATH=${T}/bin:${PATH}
	multilib-minimal_src_test
}

multilib_src_test() {
	# sandbox is breaking long symlink behavior
	local -x SANDBOX_ON=0
	local -x LD_PRELOAD=
	# some locales trigger different output that breaks tests
	local -x LC_ALL=C
	emake check
}

multilib_src_install() {
	if multilib_is_native_abi ; then
		emake DESTDIR="${D}" install

		# Create symlinks for FreeBSD
		if ! use prefix && [[ ${CHOST} == *-freebsd* ]]; then
			# Exclude cat for the time being #589876
			for bin in cpio tar; do
				dosym bsd${bin} /usr/bin/${bin}
				echo '.so bsd${bin}.1' > "${T}"/${bin}.1
				doman "${T}"/${bin}.1
			done
		fi
	else
		local install_targets=(
			install-includeHEADERS
			install-libLTLIBRARIES
			install-pkgconfigDATA
		)
		emake DESTDIR="${D}" "${install_targets[@]}"
	fi

	# Libs.private: should be used from libarchive.pc instead
	find "${ED}" -type f -name "*.la" -delete || die
}

multilib_src_install_all() {
	cd "${S}" || die
	einstalldocs
}
