# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )

inherit distutils-r1 multiprocessing prefix

DESCRIPTION="High-performance RPC framework (python libraries)"
HOMEPAGE="https://grpc.io"
SRC_URI="mirror://pypi/${PN::1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	>=dev-libs/openssl-1.1.1:0=[-bindist(-)]
	>=dev-libs/re2-0.2021.11.01:=
	dev-python/protobuf-python[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	net-dns/c-ares:=
	sys-libs/zlib:=
"

DEPEND="${RDEPEND}"

BDEPEND=">=dev-python/cython-0.28.3[${PYTHON_USEDEP}]"

PATCHES=( "${FILESDIR}/1.37.1-cc-flag-test-fix.patch" )

python_prepare_all() {
	distutils-r1_python_prepare_all
	hprefixify setup.py

	# ChromeOS: Detect SYSROOT based on environment variables rather than
	# assuming '/'. Use that SYSROOT to generate paths like ${SYSROOT}/usr/...
	# This is necessary on boards like whirlwind, whose SYSROOT is
	# /build/amd64-generic/
	sed -i "s/^LICENSE = /SYSROOT = os.environ.get('SYSROOT', '\/'); LICENSE = /" setup.py
	sed -i "s/os.path.join('\/usr',/os.path.join(SYSROOT, 'usr',/g" setup.py
}

python_configure_all() {
	# os.environ.get('GRPC_BUILD_WITH_BORING_SSL_ASM', True)
	export GRPC_BUILD_WITH_BORING_SSL_ASM=
	export GRPC_PYTHON_DISABLE_LIBC_COMPATIBILITY=1
	export GRPC_PYTHON_BUILD_SYSTEM_CARES=1
	export GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1
	export GRPC_PYTHON_BUILD_WITH_SYSTEM_RE2=1
	export GRPC_PYTHON_BUILD_SYSTEM_ZLIB=1
	export GRPC_PYTHON_BUILD_WITH_CYTHON=1
	export GRPC_PYTHON_BUILD_EXT_COMPILER_JOBS="$(makeopts_jobs)"
}
