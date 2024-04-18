# Copyright 2013 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# Original Author: The ChromiumOS Authors <chromium-os-dev@chromium.org>
# Purpose: Generate shell script containing firmware update bundle.
#

if [[ -z "${EBUILD}" ]]; then
	die "This eclass needs EBUILD environment variable."
fi

PYTHON_COMPAT=( python3_{8..9} )

inherit cros-workon cros-unibuild cros-constants python-any-r1

# Check for EAPI 7+.
case "${EAPI:-0}" in
[0123456]) die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
esac

# $board-overlay/make.conf may contain these flags to always create "firmware
# from source".
IUSE="bootimage cros_ec cros_ish tot_firmware unibuild zephyr_ec"
REQUIRED_USE="unibuild"

# "futility update" is needed when building and running updater package.
COMMON_DEPEND="
	chromeos-base/vboot_reference
"

# Apply common dependency.
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

# Dependency for run time only (invoked by `futility update`).
RDEPEND+="
	chromeos-base/vpd
	sys-apps/flashrom
	cros_ish? ( chromeos-base/chromeos-ish )
	"
# Maintenance note:  The factory install shim downloads and executes
# the firmware updater.  Consequently, run time dependencies for the
# updater are also run time dependencies for the install shim.
#
# The contents of RDEPEND must also be present in the
# chromeos-base/factory_installer ebuild in PROVIDED_DEPEND.  If you make any
# change to the list above, you may need to make a matching change in the
# factory_installer ebuild.

# Dependency to build firmware from source (build phase only).
DEPEND+="
	bootimage? ( sys-boot/chromeos-bootimage )
	cros_ec? ( chromeos-base/chromeos-ec )
	zephyr_ec? ( chromeos-base/chromeos-zephyr )
	"

RESTRICT="mirror"

# Local variables.

UPDATE_SCRIPT="chromeos-firmwareupdate"

# Add members to an array.
#  $1: Array variable to append to.
#  $2..: Arguments to append, each to be put in its own array element.
_append_var() {
	local var="$1"
	shift
	eval "${var}+=( \"\$@\" )"
}

# Add a string command-line flag with its value to an array.
# If the value is empty then this function does nothing.
#  $1: Array variable to append to.
#  $2: Flag (e.g. "-b").
#  $3: Value (e.g. "bios.bin").
_add_param() {
	local var="$1"
	local flag="$2"
	local value="$3"

	[[ -n "${value}" ]] && _append_var "${var}" "${flag}" "${value}"
}

cros-firmware_src_compile() {
	local root="${SYSROOT%/}"
	local local_root="${root}/firmware"

	# We need lddtree from chromite.
	export PATH="${CHROMITE_BIN_DIR}:${PATH}"

	# For the official BCS firmware updater.
	local ext_cmd=()
	_add_param ext_cmd -i "${DISTDIR}"
	_add_param ext_cmd -c "${root}${UNIBOARD_YAML_CONFIG}"

	# For the local firmware updater.
	local local_image_cmd=()
	local local_ext_cmd=("${ext_cmd[@]}")
	local_ext_cmd+=(--local)
	# Tell pack_firmware.py where to find the files.
	# 'BUILD_TARGET' will be replaced with the build-targets config
	# from the unified build config file. Since these path do not
	# exist, we can't use _add_file_param.
	_add_param local_image_cmd \
		-b "${local_root}/image-BUILD_TARGET.bin"
	local local_dir="${local_root}/BUILD_TARGET"
	if use zephyr_ec; then
		_add_param local_image_cmd -e "${local_dir}/ec.bin"
	elif use cros_ec; then
		_add_param local_image_cmd -e "${local_dir}/ec.bin"
	fi

	if use tot_firmware; then
		einfo "tot_firmware is enabled, skipping BCS firmware updater"
	else
		einfo "Build ${BOARD_USE} BCS firmware updater to ${UPDATE_SCRIPT}:" \
			"${ext_cmd[*]}"
		"${EPYTHON}" ./pack_firmware.py -o "${UPDATE_SCRIPT}" \
			"${ext_cmd[@]}" || die "Cannot pack firmware updater."
	fi

	# To create local updater, bootimage must be enabled.
	if ! use bootimage; then
		if use cros_ec; then
			# TODO(hungte) Deal with a platform that has
			# only EC and no BIOS, which is usually
			# incorrect configuration.  We only warn here to
			# allow for BCS based firmware to still generate
			# a proper chromeos-firmwareupdate update
			# script.
			ewarn "WARNING: platform has no local BIOS."
			ewarn "EC-only is not supported."
			ewarn "Not generating a local updater script."
		fi
		return
	fi

	# If the updater does not exist, fall back to local updater.
	if [[ ! -f "${UPDATE_SCRIPT}" ]]; then
		einfo "Build ${BOARD_USE} local updater to ${UPDATE_SCRIPT}:" \
			"${local_image_cmd[*]} ${local_ext_cmd[*]}"
		"${EPYTHON}" ./pack_firmware.py -o "${UPDATE_SCRIPT}" \
			"${local_image_cmd[@]}" "${local_ext_cmd[@]}" ||
			die "Cannot pack local firmware updater."
		if ! use tot_firmware; then
			ewarn "No BCS updater created; using local updater"
		fi
	fi

	# Create local signer config
	if use bootimage; then
		./local_signer.py -c "${root}${UNIBOARD_YAML_CONFIG}" \
			-r "${root}" || die "Cannot create local signer config."
	fi
}

cros-firmware_src_install() {
	# install updaters for firmware-from-source archive.
	if use tot_firmware && use bootimage; then
		exeinto /firmware
		newexe "${UPDATE_SCRIPT}" updater.sh
	fi

	# install local signer config
	if use bootimage; then
		insinto /firmware
		doins signer_config.csv
	fi

	# skip anything else if no main updater program.
	if [[ ! -s "${UPDATE_SCRIPT}" ]]; then
		return
	fi

	# install the main updater program if available.
	dosbin "${UPDATE_SCRIPT}"

	dosbin "${S}"/sbin/*
	# install ${FILESDIR}/sbin/* (usually board-setgoodfirmware).
	if [[ -d "${FILESDIR}"/sbin ]]; then
		dosbin "${FILESDIR}"/sbin/*
	fi
}

# Trigger tests on each firmware build. While there is a chromeos-firmware-1
# ebuild which could be used to run these tests on the host, it doesn't do
# anything at present, and the usual workflow is to build firmware for a
# particular board. This way it is more likely that people will see any
# failures in their normal workflow.
cros-firmware_src_test() {
	local fname

	# We need lddtree from chromite.
	export PATH="${CHROMITE_BIN_DIR}:${PATH}"

	for fname in *test.py; do
		einfo "Running tests in ${fname}"
		"${EPYTHON}" "./${fname}" || die "Tests failed at ${fname} (py3)"
	done
}

# @FUNCTION: cros-firmware_setup_source
# @DESCRIPTION:
# Configures all firmware binary source files to SRC_URI, and updates local
# destination mapping.
cros-firmware_setup_source() {
	# This function is called before FILESDIR is set so figure it out from
	# the ebuild filename.
	local basedir="${EBUILD%/*}"
	local files="${basedir}/files"
	local i srcf

	# Get list of all srcuri files (if any).
	# The filenames must include 'srcuris'.
	# Builtin compgen is used since it returns an empty
	# list (instead of the regexp) if there are no matches.
	mapfile -t srcf < <(compgen -G "${files}/*srcuris*")
	local uris=()
	local u
	# We can't use any external commands, so de-dup by
	# checking for an entry before adding to the list.
	for i in "${srcf[@]}"; do
		mapfile -t onefile < "${i}"
		for u in "${onefile[@]}"; do
			# The extra quoting is to avoid the shellcheck warning.
			if [[ ! " ${uris[*]} " =~ " ""${u}"" " ]]; then
				uris+=("${u}")
			fi
		done
	done

	if [[ "${#uris[@]}" -ne 0 ]]; then
		SRC_URI+=" ${uris[*]}"
	fi

	# No sources required if only building firmware from ToT.
	if [[ -n "${SRC_URI}" ]]; then
		SRC_URI="!tot_firmware? ( ${SRC_URI} )"
	fi
}

EXPORT_FUNCTIONS src_compile src_install src_test
