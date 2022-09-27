# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cros-fuzzer cros-sanitizers flag-o-matic toolchain-funcs

MY_PV="${PV//_pre/-pre}"

DESCRIPTION="Modern open source high performance RPC framework"
HOMEPAGE="https://www.grpc.io"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="examples doc systemtap static-libs"

RDEPEND="
	>=dev-libs/openssl-1.0.2:0=[-bindist]
	!dev-libs/grpc
	dev-libs/protobuf:=
	net-dns/c-ares:=
	sys-libs/zlib:=
	systemtap? ( dev-util/systemtap )
"
# 	dev-util/google-perftools

DEPEND="${RDEPEND}
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/0001-grpc-1.13.0-fix-host-ar-handling.patch"
	"${FILESDIR}/0003-grpc-1.3.0-Don-t-run-ldconfig.patch"
	"${FILESDIR}/0005-grpc-1.11.0-pkgconfig-libdir.patch"
	"${FILESDIR}/grpc-1.15.0-fix-cpp-so-version.patch"
	"${FILESDIR}/grpc-1.16.0-gcc8-fixes.patch"
	"${FILESDIR}/grpc-1.16.0-Prevent-shell-calls-longer-than-ARG_MAX.patch"
	"${FILESDIR}/grpc-1.16.1-fix-cross-compilation.patch"
	"${FILESDIR}/grpc-1.16.1-Support-vsock.patch"
	"${FILESDIR}/grpc-1.16.1-string-contatenation.patch"
	"${FILESDIR}/grpc-1.16.1-backport-glibc-gettid-fix.patch"
)

S="${WORKDIR}/${PN}-${MY_PV}"

src_prepare() {
	sed -i 's@$(prefix)/lib@$(prefix)/$(INSTALL_LIBDIR)@g' Makefile || die "fix libdir"
	sed -i 's/^install-headers_cxx:$/install-headers_cxx: install-headers_c/g' Makefile \
		|| die "failed to patch install-headers_cxx"
	default
}

src_configure() {
	default
	# Suppress "-Wnon-c-typedef-for-linkage warning, https://crbug.com/1055907
	append-flags "-Wno-non-c-typedef-for-linkage"
	if use_sanitizers; then
		# grpc ebuild need to disable some features for building with
		# sanitizers, https://crbug.com/1015125 .
		append-flags "-fno-sanitize=vptr"
		append-flags "-Wno-frame-larger-than="
	fi
}

src_compile() {
	tc-export CC CXX PKG_CONFIG

	emake \
		V=1 \
		prefix=/usr \
		INSTALL_LIBDIR="$(get_libdir)" \
		AR="$(tc-getAR)" \
		AROPTS="rcs" \
		CFLAGS="${CFLAGS}" \
		CXXFLAGS="${CXXFLAGS}" \
		LD="${CC}" \
		LDXX="${CXX}" \
		STRIP=/bin/true \
		HOST_CC="$(tc-getBUILD_CC)" \
		HOST_CXX="$(tc-getBUILD_CXX)" \
		HOST_LD="$(tc-getBUILD_CC)" \
		HOST_LDXX="$(tc-getBUILD_CXX)" \
		HOST_AR="$(tc-getBUILD_AR)" \
		HAS_SYSTEMTAP="$(usex systemtap true false)"
}

src_install() {
	emake \
		prefix="${D}"/usr \
		INSTALL_LIBDIR="$(get_libdir)" \
		STRIP=/bin/true \
		install

	use static-libs || find "${ED}" -name '*.a' -delete

	if use examples; then
		find examples -name '.gitignore' -delete || die
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi

	if use doc; then
		find doc -name '.gitignore' -delete || die
		local DOCS=( AUTHORS README.md TROUBLESHOOTING.md doc/. )
	fi

	einstalldocs
}

pkg_postinst() {
	local v
	for v in ${REPLACING_VERSIONS}; do
		if ver_test "${v}" -lt 1.16.0; then
			ewarn "python bindings and tools moved to separate independent packages"
			ewarn "check dev-python/grpcio and dev-python/grpcio-tools"
		fi
	done

}
