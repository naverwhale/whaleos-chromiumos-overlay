# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# @ECLASS: cros-zephyr-utils.eclass
# @MAINTAINER:
# ChromiumOS Firmware Team
# @BUGREPORTS:
# Please report bugs via
# https://b.corp.google.com/issues/new?component=1037860&template=1600056
# @VCSURL: https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay/+/HEAD/eclass/@ECLASS@
# @BLURB: helper eclass for building ChromiumOS firmware
# @DESCRIPTION:
# Common helper functions for working with ChromiumOS Zephyr EC firmware.

if [[ -z "${_ECLASS_CROS_ZEPHYR_UTILS}" ]]; then
_ECLASS_CROS_ZEPHYR_UTILS="1"

# Check for EAPI 7+.
case "${EAPI:-0}" in
0|1|2|3|4|5|6) die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
*) ;;
esac

PYTHON_COMPAT=( python3_{8..11} )

inherit cros-unibuild coreboot-sdk toolchain-funcs python-any-r1

LICENSE="Apache-2.0 BSD-Google"
IUSE="unibuild"
REQUIRED_USE="unibuild"

BDEPEND="
	chromeos-base/zephyr-build-tools
	dev-python/docopt
	dev-python/pykwalify
	dev-util/ninja
"

RDEPEND="${DEPEND}"

echoit() {
	einfo "$@"
	"$@"
}

# Run zmake from the EC source directory, with default arguments for
# modules and Zephyr base location for this ebuild.
run_zmake() {
	echoit env PYTHONPATH="${S}/modules/ec/zephyr/zmake" "${EPYTHON}" -m zmake -D \
		--modules-dir="${S}/modules" \
		--zephyr-base="${S}/zephyr-base" \
		"$@"
}

# @FUNCTION: cros-zephyr-compile
# @USAGE: cros-zephyr-compile <target>
# @DESCRIPTION:
# Compile Zephyr by specified target in chromeos-config.
#
# <target>: zephyr-ec or zephyr-detachable-base for Zephyr target.
cros-zephyr-compile() {
	tc-export CC

	local project
	local target=$1
	local projects=()

	if [[ -z "${target}" ]]; then
		die "Please specify zephyr build target"
	fi

	while read -r _ && read -r project; do
		if [[ -z "${project}" ]]; then
			continue
		fi

		projects+=("${project}")
	done < <(cros_config_host "get-firmware-build-combinations" "${target}" || die)
	if [[ ${#projects[@]} -eq 0 ]]; then
		einfo "No projects found."
		return
	fi
	run_zmake build -B "build" "${projects[@]}" \
		|| die "Failed to build ${projects[*]}."
}

fi  # _ECLASS_CROS_ZEPHYR_UTILS
