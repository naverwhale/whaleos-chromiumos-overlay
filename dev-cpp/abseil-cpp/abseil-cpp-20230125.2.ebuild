# Copyright 2020-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..11} )

inherit cmake cros-sanitizers flag-o-matic python-any-r1

# yes, it needs SOURCE, not just installed one
GTEST_COMMIT="v1.13.0"
GTEST_FILE="gtest-${GTEST_COMMIT#v}.tar.gz"

DESCRIPTION="Abseil Common Libraries (C++), LTS Branch"
HOMEPAGE="https://abseil.io"
SRC_URI="https://github.com/abseil/abseil-cpp/archive/${PV}.tar.gz -> ${P}.tar.gz
	test? ( https://github.com/google/googletest/archive/${GTEST_COMMIT}.tar.gz -> ${GTEST_FILE} )"

LICENSE="
	Apache-2.0
	test? ( BSD )
"
SLOT="0/${PV%%.*}"
KEYWORDS="*"
IUSE="test"

DEPEND=""
RDEPEND="${DEPEND}
	!<dev-cpp/absl-${PV}
"

BDEPEND="
	${PYTHON_DEPS}
	test? ( sys-libs/timezone-data )
"

RESTRICT="!test? ( test )"

PATCHES=(
	"${FILESDIR}"/${PN}-20230125.2-musl-1.2.4.patch #906218
	"${FILESDIR}"/use-std-optional.patch
)

ABSLDIR="${WORKDIR}/${P}_build/absl"

src_prepare() {
	cmake_src_prepare

	# un-hardcode abseil compiler flags
	sed -i \
		-e '/"-maes",/d' \
		-e '/"-msse4.1",/d' \
		-e '/"-mfpu=neon"/d' \
		-e '/"-march=armv8-a+crypto"/d' \
		absl/copts/copts.py || die

	# now generate cmake files
	python_fix_shebang absl/copts/generate_copts.py
	absl/copts/generate_copts.py || die

	if use test; then
		sed -i 's/-Werror//g' \
			"${WORKDIR}/googletest-${GTEST_COMMIT#v}"/googletest/cmake/internal_utils.cmake || die
	fi

	# ChromeOS (b/264420866): Enable a "hardened" build.
	sed -i 's/^#define ABSL_OPTION_HARDENED 0/#define ABSL_OPTION_HARDENED 1/' \
		absl/base/options.h || die
}

src_configure() {
	append-lfs-flags
	sanitizers-setup-env  # ChromeOS-specific asan fix.
	local mycmakeargs=(
		-DCMAKE_CXX_STANDARD=17
		-DABSL_ENABLE_INSTALL=TRUE
		-DABSL_LOCAL_GOOGLETEST_DIR="${WORKDIR}/googletest-${GTEST_COMMIT#v}"
		-DABSL_PROPAGATE_CXX_STD=TRUE
		-DABSL_BUILD_TESTING=$(usex test ON OFF)
		$(usex test -DBUILD_TESTING=ON '') #intentional usex, it used both variables for tests.
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile

	local libs=( "${ABSLDIR}"/*/libabsl_*.so )
	[[ ${#libs[@]} -le 1 ]] && die
	local linklibs="$(echo "${libs[*]}" | sed -E -e 's|[^ ]*/lib([^ ]*)\.so|-l\1|g')"
	sed -e "s/@LIBS@/${linklibs}/g" -e "s/@PV@/${PV}/g" \
		"${FILESDIR}/absl.pc.in" > absl.pc || die
}

src_install() {
	cmake_src_install

	insinto "/usr/$(get_libdir)/pkgconfig"
	doins absl.pc

	# absl adds all the Cflags to all the pc files even though almost all the
	# .pc files require abs_config.pc. This causes an explosion of flags when
	# including multiple abseil sub-libraries through pkg-config. Until the
	# issue is fixed upstream, strip them out here since this is easier to
	# maintain than a version specific patch.
	find "${D}/usr/$(get_libdir)/pkgconfig" -type f -print0 -not -name 'absl_config.pc' | xargs -0 sed -i '/^Cflags: /d' || die
}
