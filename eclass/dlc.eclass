# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# @MAINTAINER:
# Chromium OS System Services Team
# @AUTHOR
# The Chromium OS Authors <chromium-os-dev@chromium.org>
# @BUGREPORTS:
# Please report bugs via http://crbug.com/new
# @BLURB: Helper eclass for building DLC packages.
# @DESCRIPTION:
# Handles building the DLC image and metadata files and dropping them into
# locations where they can be picked up by the build process and hosted on
# Omaha, respectively.

if [[ -z "${_ECLASS_DLC}" ]]; then
_ECLASS_DLC="1"

inherit cros-constants

# Check for EAPI 6+.
case "${EAPI:-0}" in
[012345]) die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
esac

DLC_BUILD_DIR="build/rootfs/dlc"

# @ECLASS-VARIABLE: DLC_PREALLOC_BLOCKS
# @DEFAULT_UNSET
# @REQUIRED
# @DESCRIPTION:
# The number of blocks to preallocate for each of the the DLC A/B partitions.
# Block size is 4 KiB.

# Other optional DLC ECLASS-VARAIBLES

# @ECLASS-VARIABLE: DLC_NAME
# @DEFAULT_UNSET
# @REQUIRED
# @DESCRIPTION:
# The name of the DLC to show on the UI.
: "${DLC_NAME:=${PN}}"

# @ECLASS-VARIABLE: DLC_DESCRIPTION
# @DESCRIPTION:
# A human readable description for DLC.

# @ECLASS-VARIABLE: DLC_ID
# @DESCRIPTION:
# Unique ID for the DLC among all DLCs. Needed to generate metadata for
# imageloader. Used in creating directories for the image file and metadata. It
# cannot contain '_' or '/'.
: "${DLC_ID:=${PN}}"

# @ECLASS-VARIABLE: DLC_PACKAGE
# @DESCRIPTION:
# Unique ID for the package in the DLC. Each DLC can have multiple
# packages. Needed to generate metadata for imageloader. Used in creating
# directories for the image file and metadata. It cannot contain '_' or '/'.
: "${DLC_PACKAGE:=package}"

# @ECLASS-VARIABLE: DLC_VERSION
# @DESCRIPTION:
# Version of the DLC being built.
: "${DLC_VERSION:=${PVR}}"

# @ECLASS-VARIABLE: DLC_FS_TYPE
# @DEFAULT UNSET
# @DESCRIPTION:
# Specify the type of filesystem for the DLC image. Currently we only support
# squashfs.

# @ECLASS-VARIABLE: DLC_PRELOAD
# @DESCRIPTION:
# Determines whether to preload the DLC for test images. A boolean must be
# passed in.
: "${DLC_PRELOAD:="false"}"

# @ECLASS-VARIABLE: DLC_ENABLED
# @DESCRIPTION:
# Determines whether the package will be a DLC package or regular package.
# By default, the package is a DLC package and the files will be installed in
# ${DLC_BUILD_DIR}/${DLC_ID}/${DLC_PACKAGE}/root, but if the variable is set to
# "false", all the functions will ignore the path suffix and everything that
# would have been installed inside the DLC, gets installed in the rootfs.
: "${DLC_ENABLED:="true"}"

# @ECLASS-VARIABLE: DLC_USED_BY
# @DESCRIPTION:
# Determines the user of the DLC, e.g. device users vs. system, so
# dlcservice/UI can make predictable actions based on that. Acceptable values
# are "system" and "user".
: "${DLC_USED_BY:=system}"

# @ECLASS-VARIABLE: DLC_DAYS_TO_PURGE
# @DESCRIPTION:
# Defines how many days the DLC should be kept before purging it from disk after
# it has been uninstalled. Default is 5 days.
: "${DLC_DAYS_TO_PURGE:=5}"

# @ECLASS-VARIABLE: DLC_MOUNT_FILE_REQUIRED
# @DESCRIPTION:
# By default, DLC mount points should be retrieved from the DBUS install method.
# Places where DBus isn't accessible, use this flag to generate a file holding
# the mount point as an indirect method of retrieving the DLC mount point.
: "${DLC_MOUNT_FILE_REQUIRED:="false"}"

# @FUNCTION: dlc_add_path
# @USAGE: <path to add the DLC prefix to>
# @RETURN:
# Adds the DLC path prefix to the argument based on the value of |DLC_ENABLED|
# and returns that value.
dlc_add_path() {
	[[ $# -eq 1 ]] || die "${FUNCNAME}: takes one argument"
	local input_path="$1"
	if [[ "${DLC_ENABLED}" != "true" ]]; then
		echo "/${input_path}"
	else
		[[ -z "${DLC_ID}" ]] && die "DLC_ID undefined"
		[[ -z "${DLC_PACKAGE}" ]] && die "DLC_PACKAGE undefined"
		echo "/${DLC_BUILD_DIR}/${DLC_ID}/${DLC_PACKAGE}/root/${input_path}"
	fi
}

# @FUNCTION: dlc_src_install
# @DESCRIPTION:
# Installs DLC files into
# /build/${BOARD}/${DLC_BUILD_DIR}/${DLC_ID}/${DLC_PACKAGE}/root.
dlc_src_install() {
	[[ "${DLC_ENABLED}" =~ ^(true|false)$ ]] || die "Invalid DLC_ENABLED value"
	if [[ "${DLC_ENABLED}" != "true" ]]; then
		return
	fi

	# Required.
	[[ -z "${DLC_NAME}" ]] && die "DLC_NAME undefined"
	[[ -z "${DLC_PREALLOC_BLOCKS}" ]] && die "DLC_PREALLOC_BLOCKS undefined"

	# Optional, but error if derived default values are empty.
	: "${DLC_DESCRIPTION:=${DESCRIPTION}}"
	[[ -z "${DLC_DESCRIPTION}" ]] && die "DLC_DESCRIPTION undefined"
	[[ -z "${DLC_ID}" ]] && die "DLC_ID undefined"
	[[ -z "${DLC_PACKAGE}" ]] && die "DLC_PACKAGE undefined"
	[[ -z "${DLC_VERSION}" ]] && die "DLC_VERSION undefined"
	[[ "${DLC_PRELOAD}" =~ ^(true|false)$ ]] || die "Invalid DLC_PRELOAD value"
	[[ -z "${DLC_USED_BY}" ]] && die "DLC_USED_BY undefined"
	[[ "${DLC_MOUNT_FILE_REQUIRED}" =~ ^(true|false)$ ]] \
		|| die "Invalid DLC_MOUNT_FILE_REQUIRED value"

	local args=(
		--install-root-dir="${D}"
		--pre-allocated-blocks="${DLC_PREALLOC_BLOCKS}"
		--version="${DLC_VERSION}"
		--id="${DLC_ID}"
		--package="${DLC_PACKAGE}"
		--name="${DLC_NAME}"
		--description="${DLC_DESCRIPTION}"
		--fullnamerev="${CATEGORY}/${PF}"
		--build-package
		--days-to-purge="${DLC_DAYS_TO_PURGE}"
	)

	if [[ -n "${DLC_FS_TYPE}" ]]; then
		args+=( --fs-type="${DLC_FS_TYPE}" )
	fi

	if [[ "${DLC_PRELOAD}" == "true" ]]; then
		args+=( --preload )
	fi

	if [[ -n "${DLC_USED_BY}" ]]; then
		args+=( --used-by="${DLC_USED_BY}" )
	fi

	if [[ "${DLC_MOUNT_FILE_REQUIRED}" == "true" ]]; then
		args+=( --mount-file-required )
	fi

	"${CHROMITE_BIN_DIR}"/build_dlc "${args[@]}" \
		|| die "build_dlc failed."
}

EXPORT_FUNCTIONS src_install

fi
