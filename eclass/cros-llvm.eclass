# Copyright 2017 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2.

# @ECLASS: cros-llvm.eclass
# @MAINTAINER:
# ChromeOS toolchain team.<chromeos-toolchain@google.com>

# @DESCRIPTION:
# Functions to set the right toolchains and install prefix for llvm
# related libraries in crossdev stages.

inherit multilib

IUSE="continue-on-patch-failure python_targets_python3_6"

BDEPEND="python_targets_python3_6? ( dev-python/dataclasses )"
if [[ ${CATEGORY} == cross-* ]] ; then
	DEPEND="
		${CATEGORY}/binutils
		${CATEGORY}/gcc
		sys-devel/llvm
		"
fi

export CBUILD=${CBUILD:-${CHOST}}
export CTARGET=${CTARGET:-${CHOST}}

if [[ "${CTARGET}" = "${CHOST}" ]] ; then
	if [[ "${CATEGORY/cross-}" != "${CATEGORY}" ]] ; then
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
		export AS="$(tc-getAS "${CTARGET}")"
		export STRIP="$(tc-getSTRIP "${CTARGET}")"
		export OBJCOPY="$(tc-getOBJCOPY "${CTARGET}")"
	elif [[ "${CTARGET}" != "${CBUILD}" ]] ; then
		export CC="${CTARGET}-clang"
		export CXX="${CTARGET}-clang++"
	fi
	unset ABI MULTILIB_ABIS DEFAULT_ABI
	multilib_env "${CTARGET}"
}

# @FUNCTION: prepare_patches
# @USAGE: <SVN Revision>
# @DESCRIPTION:
# Applies the LLVM patches to the LLVM source at `$S`. If the SVN revision
# is not passed in, then it will be extracted from the `$PV` for non-9999 /
# non-llvm-{next,tot} ebuilds. Otherwise it will inspect the .git directory
# to compute the SVN revision.
prepare_patches() {
	local failure_mode
	failure_mode="$(usex continue-on-patch-failure continue fail)"

	local revision
	if [[ $# -ge 1 ]]; then
		revision="$1"
	else
		revision="$(get_most_recent_revision)"
	fi

	"${FILESDIR}"/patch_manager/patch_manager.py \
		--svn_version "${revision}" \
		--patch_metadata_file "${FILESDIR}"/PATCHES.json \
		--failure_mode "${failure_mode}" \
		--src_path "${S}" || die
}

# shellcheck disable=SC2120
get_most_recent_revision() {
	# b/293822345 - Don't depend on the .git repo for versioned builds.
	if [[ "${PV}" != "9999" ]] && use !llvm-next; then
		# 17.0_pre496208 -> 496208
		ver_cut 4
		return
	fi

	local subdir="${1:-"${S}/llvm"}"
	# Tries to get the revision ID of the most recent commit
	local rev current_git_head
	current_git_head="$(git -C "${subdir}" rev-parse HEAD)" || die
	rev="$("${FILESDIR}"/patch_manager/git_llvm_rev.py --llvm_dir "${subdir}" --sha="${current_git_head}")" || die "failed to get most recent llvm revision from ${subdir}"
	cut -d 'r' -f 2 <<< "${rev}"
}

is_baremetal_abi() {
	# ABIs like armv7m-cros-eabi or arm-none-eabi.
	if [[ "${CTARGET}" == *-eabi ]]; then
		return 0
	fi
	return 1
}

# @FUNCTION cros-llvm_default_preclone_hook
# @DESCRIPTION:
# A function that takes in a global variable "path", to determine the
# location of the llvm-project git, and writes it to a tempfile ${T}/llvm-rev.
# This is useful when we need to get the svn revision number but we don't
# have access to this information from the ebuild itself.
#
# Used for cros-workon live ebuild support (PV=9999).
cros-llvm_default_preclone_hook() {
	# "path" is defined as a global in the cros-workon.eclass
	# shellcheck disable=SC2154
	local project_path="${path[0]}"
	if [[ -d "${project_path}" ]]; then
		get_most_recent_revision "${project_path}" > "${T}/llvm-rev"
	fi

}
