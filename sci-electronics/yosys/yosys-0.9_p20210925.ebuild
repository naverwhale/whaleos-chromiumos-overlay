# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="A framework for Verilog RTL synthesis."
HOMEPAGE="http://www.clifford.at/yosys/"

GIT_REV="1cac671c70bc3da9808ceb3add15686da4a5d82e"

# These have to match Yosys Makefile's ABCREV and ABCURL variables.
ABC_GIT_REV="4f5f73d"
ABC_GIT_URL="https://github.com/YosysHQ/abc"

SRC_URI="
	https://github.com/YosysHQ/yosys/archive/${GIT_REV}.tar.gz -> yosys-${GIT_REV}.tar.gz
	${ABC_GIT_URL}/archive/${ABC_GIT_REV}.tar.gz -> yosys-abc-${ABC_GIT_REV}.tar.gz
"

S="${WORKDIR}/${PN}-${GIT_REV}"

LICENSE="ISC"
SLOT="0"
KEYWORDS="*"

DEPEND=""
RDEPEND="${DEPEND} sci-electronics/iverilog"

PATCHES=(
	"${FILESDIR}/yosys-fix-Makefile-tools.patch"
)

src_unpack() {
	default

	# Yosys' Makefile expects ABC in the 'abc' directory.
	cd "${S}"
	mv ../abc-* abc || die

	# Make sure Makefile's ABCURL and ABCREV match ebuild ones.
	if ! grep -q "^ABCURL.*= ${ABC_GIT_URL}" Makefile; then
		die "ABC git URL mismatch between ebuild and Yosys' Makefile!"
	fi

	if ! grep -q "^ABCREV.*= ${ABC_GIT_REV}" Makefile; then
		die "ABC git revision mismatch between ebuild and Yosys' Makefile!"
	fi
}

src_configure() {
	cat >> Makefile.conf <<-EOF
		# ABC from 'abc' dir will be used
		ABCREV := default
		LD := $(tc-getCXX)
		PKG_CONFIG := $(tc-getPKG_CONFIG)
		PREFIX := /usr
		# Prevent stripping
		STRIP := :
	EOF
}

# The default function doesn't call it because 'emake test -n' fails.
src_test() {
	emake test
}
