# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

# @ECLASS: cros-llvm.eclass
# @MAINTAINER:
# ChromeOS toolchain team.<chromeos-toolchain@google.com>

# @DESCRIPTION:
# Functions to set the right toolchains and install prefix for llvm
# related libraries in crossdev stages.

inherit multilib

if [[ ${CATEGORY} == cross-* ]] ; then
	DEPEND="
		${CATEGORY}/binutils
		${CATEGORY}/gcc
		sys-devel/llvm
		"
fi

export CBUILD=${CBUILD:-${CHOST}}
export CTARGET=${CTARGET:-${CHOST}}

if [[ ${CTARGET} = ${CHOST} ]] ; then
	if [[ ${CATEGORY/cross-} != ${CATEGORY} ]] ; then
		export CTARGET=${CATEGORY/cross-}
	fi
fi

setup_cross_toolchain() {
	export CC="${CBUILD}-clang"
	export CXX="${CBUILD}-clang++"
	export PREFIX="/usr"

	if [[ ${CATEGORY} == cross-* ]] ; then
		export CC="${CTARGET}-clang"
		export CXX="${CTARGET}-clang++"
		export PREFIX="/usr/${CTARGET}/usr"
		export AS="$(tc-getAS ${CTARGET})"
		export STRIP="$(tc-getSTRIP ${CTARGET})"
		export OBJCOPY="$(tc-getOBJCOPY ${CTARGET})"
	elif [[ ${CTARGET} != ${CBUILD} ]] ; then
		export CC="${CTARGET}-clang"
		export CXX="${CTARGET}-clang++"
	fi
	unset ABI MULTILIB_ABIS DEFAULT_ABI
	multilib_env ${CTARGET}
}

get_most_recent_revision() {
	local subdir="${S}/llvm"
	# Tries to get the revision ID of the most recent commit
	"${FILESDIR}"/patch_manager/git_llvm_rev.py --llvm_dir "${subdir}" --sha "$(git -C "${subdir}" rev-parse HEAD)" | cut -d 'r' -f 2
}
