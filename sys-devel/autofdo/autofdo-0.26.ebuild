# Copyright 2021 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic cmake

DESCRIPTION="Utility for generating AFDO profiles"
HOMEPAGE="http://gcc.gnu.org/wiki/AutoFDO"
SRC_URI="https://github.com/google/${PN}/archive/${PV}.tar.xz -> ${P}.tar.xz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	dev-cpp/abseil-cpp:=
	dev-cpp/gflags
	dev-libs/openssl:0=
	dev-libs/protobuf:=
	dev-libs/libffi
	sys-devel/llvm
	sys-libs/ncurses:0=
	sys-libs/zlib"
RDEPEND="${DEPEND}"

PATCHES=()

src_unpack() {
	default

	# Remove the bundled absl and use the system absl headers.
	# Symlink the the system headers so they are available at the
	# expected local path.
	rm -r "${S}/third_party/abseil" || die
	mkdir -p "${S}/third_party/abseil" || die
	ln -s "${SYSROOT}/usr/include/absl" "${S}/third_party/abseil/"
}

src_prepare() {
	eapply "${FILESDIR}/${PN}-Fix-llvm-Optional.patch"
	eapply "${FILESDIR}/${PN}-Fix-FileSystem-arg.patch"

	local llvm_version
	llvm_version=$(llvm-config --version) || die
	[[ ${llvm_version/.*/} -ge 18 ]] && eapply "${FILESDIR}/${PN}-Fix-for-llvm-18.patch"

	eapply_user

	# Use the system absl instead of the bundled absl.
	sed -i -e 's/add_subdirectory(third_party\/abseil)/find_package(absl REQUIRED)/g' \
		"${S}/CMakeLists.txt" || die

	cmake_src_prepare
}

src_configure() {
	append-ldflags "$(no-as-needed)"
	local mycmakeargs=(
		"-DBUILD_SHARED_LIBS=NO"
		"-DBUILD_TESTING=OFF"
		"-DINSTALL_GTEST=OFF"
		"-DLLVM_PATH=$(llvm-config --cmakedir)"
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile create_llvm_prof profile_merger sample_merger
}

src_install() {
	dobin "${BUILD_DIR}"/create_llvm_prof "${BUILD_DIR}"/profile_merger \
		"${BUILD_DIR}"/sample_merger
}
