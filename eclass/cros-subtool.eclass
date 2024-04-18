# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: cros-subtool.eclass
# @MAINTAINER:
# ChromiumOS Build Team
# @BLURB: Helper eclass to register with the Subtools builder: go/sdk-subtools.

if [[ -z "${_CROS_SUBTOOL_ECLASS}" ]]; then
_CROS_SUBTOOL_ECLASS="1"

# @FUNCTION: cros-subtool_src_install
# @USAGE: [SUBTOOL_TEXTPROTOS...]
# @DESCRIPTION:
# Installs the provided subtool definitions. With no argument, adds the single
# definition file at ${FILESDIR}/${PN}_subtool.textproto
cros-subtool_src_install() {
	local subtools=("$@")
	if [[ $# -eq 0 ]] ; then
		subtools=("${FILESDIR}/${PN}_subtool.textproto")
	fi
	einfo "Installing subtool definitions: ${subtools[*]}"
	(
		insinto "/etc/cros/sdk-packages.d/${PN}"
		doins "${subtools[@]}"
	)
}

fi

EXPORT_FUNCTIONS src_install
