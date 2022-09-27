# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils toolchain-funcs

DESCRIPTION="Abseil - C++ Common Libraries"
HOMEPAGE="https://abseil.io"
SRC_URI="https://github.com/abseil/abseil-cpp/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=""
DEPEND=""

S="${WORKDIR}/abseil-cpp-${PV}"
ABSLDIR="${WORKDIR}/${P}_build/absl"

src_prepare() {
	# Workaround to avoid conflict with other packages: see also b/184603259
	grep -l -R -Z "absl::" . | xargs -0 sed -i 's/absl::/absl::ABSL_OPTION_INLINE_NAMESPACE_NAME::/g'
	default
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=on
		-DCMAKE_CXX_STANDARD=17
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	local libs=( "${ABSLDIR}"/*/libabsl_*.so )
	[[ ${#libs[@]} -le 1 ]] && die
	local linklibs="$(echo "${libs[*]}" | sed -E -e 's|[^ ]*/lib([^ ]*)\.so|-l\1|g')"
	sed -e "s/@LIBS@/${linklibs}/g" "${FILESDIR}/absl.pc.in" > absl.pc || die
}

src_install() {
	cmake-utils_src_install

	insinto /usr/$(get_libdir)/pkgconfig
	doins absl.pc
}
