# Copyright 2012 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

# Track all numbered kernel repos.
# This array is static due to tooling limitations. Specically, inheriting
# cros-kernel-versions doesn't consistently work in all of the ways that this
# ebuild is processed.
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
KEYWORDS="~*"
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
