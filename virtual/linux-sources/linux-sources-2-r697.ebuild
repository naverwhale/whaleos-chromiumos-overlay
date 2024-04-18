# Copyright 2012 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

# Track all numbered kernel repos.
# This array is static due to tooling limitations. Specically, inheriting
# cros-kernel-versions doesn't consistently work in all of the ways that this
# ebuild is processed.
CROS_WORKON_COMMIT=("ed51372021187d02a07802e1815b2344e9fea563" "f337c53c4a2f11029e18062a1f41cf47c3c0e5ec" "58621169d4183d702bdb9f6c60e1c085834a15c0" "1ad8bc5491d44e7483b31853cfd770cbf4f22b3d" "24e6bf8e5d11042ea483f095f6df4ddbd747248c" "0f1a27f8b19cf938468e80ccd547dda3894a8043")
CROS_WORKON_TREE=("44901dadc4436b1e650e262aaf381c20e6c5016d" "be290dc5452f1ded2a3b11e1809c8ebf75c18e26" "f089c82b0eba88da8328b117cf6a5bf2380f18db" "d6f32b344a23fac452e4eea1e3b46c2d059b6b59" "be01cb066c3f3c937c3073f01aca4d0bac76b989" "fde1e144e7020ea2e78e4e8adc459df5190fc9a5")
CROS_WORKON_PROJECT=(
	"chromiumos/third_party/kernel"
	"chromiumos/third_party/kernel"
	"chromiumos/third_party/kernel"
	"chromiumos/third_party/kernel"
	"chromiumos/third_party/kernel"
	"chromiumos/third_party/kernel"
)
CROS_WORKON_LOCALNAME=(
	"kernel/v4.14"
	"kernel/v4.19"
	"kernel/v5.4"
	"kernel/v5.10"
	"kernel/v5.15"
	"kernel/v6.1"
)

inherit cros-workon cros-kernel-versions

DESCRIPTION="Chrome OS Kernel virtual package"
HOMEPAGE="http://src.chromium.org"

LICENSE="metapackage"
KEYWORDS="*"
S="${WORKDIR}"

# Check if the static arrays defined above need to be updated to reflect a
# change to cros-kernel-versions' CHROMEOS_KERNELS.
assert_localname_sync() {
	local k v actual expected expected_localname=()
	# shellcheck disable=SC2154
	for k in "${CHROMEOS_KERNELS[@]}"; do
		if [[ "${k}" =~ chromeos-kernel-([0-9]+_[0-9]+) ]]; then
			v="${BASH_REMATCH[1]//_/.}"
			expected="kernel/v${v}"
			expected_localname+=("${expected}")
			if [[ ! "${CROS_WORKON_LOCALNAME[*]}" =~ ${expected} ]]; then
				die "Append ${expected} to ${CATEGORY}/${PN} CROS_WORKON_LOCALNAME"
			fi
		fi
	done
	for actual in "${CROS_WORKON_LOCALNAME[@]}"; do
		if [[ ! "${expected_localname[*]}" =~ ${actual} ]]; then
			die "Remove ${actual} from ${CATEGORY}/${PN} CROS_WORKON_LOCALNAME"
		fi
	done
}

# shellcheck disable=SC2154
IUSE="${!CHROMEOS_KERNELS[*]}"
# exactly one of foo, bar, or baz must be set, but not several
REQUIRED_USE="^^ ( ${!CHROMEOS_KERNELS[*]} )"

# shellcheck disable=SC2154
RDEPEND="
	$(for v in "${!CHROMEOS_KERNELS[@]}"; do echo  "${v}? (  sys-kernel/${CHROMEOS_KERNELS[${v}]} )"; done)
"

# Add blockers so when migrating between USE flags, the old version gets
# unmerged automatically.
# shellcheck disable=SC2154
RDEPEND+="
	$(for v in "${!CHROMEOS_KERNELS[@]}"; do echo "!${v}? ( !sys-kernel/${CHROMEOS_KERNELS[${v}]} )"; done)
"

# Default to the latest kernel if none has been selected.
# TODO: This defaulting does not work. Fix or remove.
RDEPEND_DEFAULT="sys-kernel/chromeos-kernel-5_4"
# Here be dragons!
RDEPEND+="
	$(printf '!%s? ( ' "${!CHROMEOS_KERNELS[@]}")
	${RDEPEND_DEFAULT}
	$(printf '%0.s) ' "${!CHROMEOS_KERNELS[@]}")
"

src_unpack() {
	# Perform our assertions within a src_*() phase rather than at global
	# scope, so they only trigger when this package is in active use,
	# rather than when it is simply sourced.
	assert_localname_sync
}
