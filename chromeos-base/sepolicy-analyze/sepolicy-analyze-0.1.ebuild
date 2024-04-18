# Copyright 2019 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit toolchain-funcs

SEPOL_VER="2.7"

DESCRIPTION="SELinux policy compiler"
HOMEPAGE="http://userspace.selinuxproject.org"
SRC_URI="https://android.googlesource.com/platform/system/sepolicy/+archive/refs/tags/android-cts-9.0_r7/tools/sepolicy-analyze.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

DEPEND=">=sys-libs/libsepol-${SEPOL_VER}:="

S="${WORKDIR}"

src_compile() {
	# shellcheck disable=SC2207,SC2206
	local cmd=(
		$(tc-getCC) *.c
		${CFLAGS} ${CPPFLAGS} ${LDFLAGS}
		# We have to statically link because the code uses internal symbols
		# that are not exported in libsepol.so.
		-static
		$($(tc-getPKG_CONFIG) --libs --cflags libsepol)
		-o sepolicy-analyze
	)
	echo "${cmd[@]}"
	"${cmd[@]}" || die
}

src_install() {
	dobin sepolicy-analyze
}
