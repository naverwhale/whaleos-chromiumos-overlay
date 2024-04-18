# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: cros-rmad.eclass
# @BLURB: helper eclass for building Chromium packages of RMA daemon
# @DESCRIPTION:
# Package src/platform2/rmad is in active development.  We have to add
# board-specific rules manually.

if [[ -z "${_CROS_RMAD_ECLASS}" ]]; then
_CROS_RMAD_ECLASS="1"

# Check for EAPI 7+.
case "${EAPI:-0}" in
[0123456]) die "Unsupported EAPI=${EAPI:-0} (too old) for ${ECLASS}";;
esac

# @FUNCTION: cros-rmad_src_install
# @DESCRIPTION:
# Install RMA daemon config files.
cros-rmad_src_install() {
	if [[ -d "${FILESDIR}/rmad/" ]]; then
		insinto /etc/rmad
		doins -r "${FILESDIR}/rmad/"*
	fi
}

fi
