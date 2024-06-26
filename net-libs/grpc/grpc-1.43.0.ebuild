# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cros-fuzzer cros-sanitizers cmake

MY_PV="${PV//_pre/-pre}"

DESCRIPTION="Modern open source high performance RPC framework"
HOMEPAGE="https://www.grpc.io"
SRC_URI="https://github.com/${PN}/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
# format is 0/${CORE_SOVERSION//./}.${CPP_SOVERSION//./} , check top level CMakeLists.txt
SLOT="0/21.143"
KEYWORDS="*"
IUSE="cros_host doc examples test"

# look for submodule versions in third_party dir
RDEPEND="
	>=dev-cpp/abseil-cpp-20211102.0:=
	>=dev-libs/re2-0.2021.11.01:=
	>=dev-libs/openssl-1.1.1:0=[-bindist(-)]
	>=dev-libs/protobuf-3.18.1:=
	dev-libs/xxhash
	>=net-dns/c-ares-1.15.0:=
	!net-libs/grpc:1.16.1
	sys-libs/zlib:=
"

DEPEND="${RDEPEND}
	test? (
		dev-cpp/benchmark
		dev-cpp/gflags
	)
"

BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${P}-support-vsock.patch"
	"${FILESDIR}/${P}-build-codegen.patch"
	"${FILESDIR}/${P}-Add-a-VsockResolverFactory.patch"
	"${FILESDIR}/${P}-Fix-proto-ODR-issue.patch"
)

# requires sources of many google tools
RESTRICT="test"

S="${WORKDIR}/${PN}-${MY_PV}"

soversion_check() {
	local core_sover cpp_sover
	# extract quoted number. line we check looks like this: 'set(gRPC_CPP_SOVERSION    "1.37")'
	core_sover="$(grep 'set(gRPC_CORE_SOVERSION ' CMakeLists.txt  | sed '/.*\"\(.*\)\".*/ s//\1/')"
	cpp_sover="$(grep 'set(gRPC_CPP_SOVERSION ' CMakeLists.txt  | sed '/.*\"\(.*\)\".*/ s//\1/')"
	# remove dots, e.g. 1.37 -> 137
	core_sover="${core_sover//./}"
	cpp_sover="${cpp_sover//./}"
	[[ ${core_sover} -eq $(ver_cut 2 ${SLOT}) ]] || die "fix core sublot! should be ${core_sover}"
	[[ ${cpp_sover} -eq $(ver_cut 3 ${SLOT}) ]] || die "fix cpp sublot! should be ${cpp_sover}"
}

src_prepare() {
	cmake_src_prepare

	# un-hardcode libdir
	sed -i "s@lib/pkgconfig@$(get_libdir)/pkgconfig@" CMakeLists.txt || die
	sed -i "s@/lib@/$(get_libdir)@" cmake/pkg-config-template.pc.in || die

	soversion_check
}

src_configure() {
	# Suppress "-Wnon-c-typedef-for-linkage warning, https://crbug.com/1055907
	append-flags "-Wno-non-c-typedef-for-linkage"
	sanitizers-setup-env  # ChromeOS-specific asan fix.
	if use_sanitizers; then
		# grpc ebuild need to disable some features for building with
		# sanitizers, https://crbug.com/1015125 .
		append-flags "-fno-sanitize=vptr"
		append-flags "-Wno-frame-larger-than="
	fi

	local mycmakeargs=(
		-DgRPC_INSTALL=ON
		-DgRPC_ABSL_PROVIDER=package
		-DgRPC_BACKWARDS_COMPATIBILITY_MODE=OFF
		-DgRPC_CARES_PROVIDER=package
		-DgRPC_INSTALL_CMAKEDIR="$(get_libdir)/cmake/${PN}"
		-DgRPC_INSTALL_LIBDIR="$(get_libdir)"
		-DgRPC_PROTOBUF_PROVIDER=package
		-DgRPC_RE2_PROVIDER=package
		-DgRPC_SSL_PROVIDER=package
		-DgRPC_ZLIB_PROVIDER=package
		-DgRPC_BUILD_TESTS=$(usex test)
		-DCMAKE_CXX_STANDARD=17
		$(usex test '-DgRPC_BENCHMARK_PROVIDER=package' '')

	)

	# ChromeOS: Disable protoc plugins if cross-compiling since protoc is not
	# available on the target.
	if ! use cros_host; then
		mycmakeargs+=(
			-DgRPC_BUILD_CODEGEN=OFF
			-DgRPC_BUILD_GRPC_CPP_PLUGIN=OFF
			-DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF
			-DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF
			-DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF
			-DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF
			-DgRPC_BUILD_GRPC_PYTHON_PLUGIN=OFF
			-DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF
		)
	fi
	cmake_src_configure
}

src_install() {
	cmake_src_install

	if use examples; then
		find examples -name '.gitignore' -delete || die
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi

	if use doc; then
		find doc -name '.gitignore' -delete || die
		local DOCS=( AUTHORS CONCEPTS.md README.md TROUBLESHOOTING.md doc/. )
	fi

	einstalldocs
}
