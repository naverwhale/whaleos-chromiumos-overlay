# Copyright 2017 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "083569b82e5bcbfefd8700a2cd52ea619e712f7a" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk libpasswordprovider .gn"

PLATFORM_SUBDIR="libpasswordprovider"

inherit cros-workon platform

DESCRIPTION="Library for storing and retrieving user password"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/libpasswordprovider"

LICENSE="BSD-Google"
KEYWORDS="*"

RDEPEND="
	sys-apps/keyutils:=
"

DEPEND="${RDEPEND}"

src_install() {
	platform_src_install

	dolib.so "${OUT}/lib/libpasswordprovider.so"

	insinto "/usr/$(get_libdir)/pkgconfig"
	doins libpasswordprovider.pc

	insinto "/usr/include/libpasswordprovider"
	doins *.h
}

platform_pkg_test() {

	platform_test "run" "${OUT}/${test_bin}" "0" "${gtest_filter}"
}

platform_pkg_test() {
	local gtest_filter=""
	if ! use x86 && ! use amd64 ; then
		# PasswordProvider tests fail on qemu due to unsupported system calls to keyrings.
		# Run only the Password unit tests on qemu since keyrings are not supported yet.
		# https://crbug.com/792699
		einfo "Skipping PasswordProvider unit tests on non-x86 platform"
		gtest_filter+="Password.*"
	fi

	local tests=(
		password_provider_test
	)

	local test_bin
		for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}" 0 "${gtest_filter}"
	done
}
