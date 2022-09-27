# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
#
# Standardizes the setup for chromeos-config-bsp ebuilds across
# all overlays based on config managed in the project specific
# repos (located under src/project).

# Check for EAPI 7+
case "${EAPI:-0}" in
7) ;;
*) die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
esac


# @ECLASS-VARIABLE: PROGRAM
# @PRE_INHERIT
# @REQUIRED
# @DESCRIPTION:
# Name of the program under src/program
: "${PROGRAM:=alpha}"


# @ECLASS-VARIABLE: PROJECTS
# @PRE_INHERIT
# @REQUIRED
# @DESCRIPTION:
# Names of the projects under src/project/$PROGRAM/ that will be
# included in this build.
: "${PROJECTS:=(one two three)}"

PROJECT_PREFIX="project_"
PROJECT_ALL="${PROJECT_PREFIX}all"
IUSE="${PROJECT_ALL} ${PROJECTS[*]/#/${PROJECT_PREFIX}}"

# Watch for any change anywhere in the projects or program
export CONFIG_ROOT=""

inherit cros-unibuild cros-constants

SRC_URI=""

LICENSE="BSD-Google"
SLOT="0/${PF}"

BDEPEND="
	dev-go/lucicfg
"

src_compile() {
	# Re-establish the symlinks as they exist in the source tree
	ln -s "${S}/config" "${S}/${PROGRAM}/config"
	(cd "${S}/${PROGRAM}" && \
		lucicfg generate --config-dir generated config.star \
		) || die "Failed to generate '${PROGRAM}' from source starlark"
	for project in "${PROJECTS[@]}"; do
		ln -s "${S}/config" "${S}/${project}/config"
		ln -s "${S}/${PROGRAM}" "${S}/${project}/program"
		output_dir="sw_build_config/platform/chromeos-config/generated"
		(cd "${S}/${project}" && \
			lucicfg generate --config-dir generated config.star && \
			cros_config_proto_converter \
			--output "${output_dir}/project-config.json" \
			--program_config "${S}/${PROGRAM}/generated/config.jsonproto" \
			--project_configs "${S}/${project}/generated/config.jsonproto"
					) || die "Failed to generate '${project}' config from source starlark"
	done
	platform_json_compile
}


src_install() {
	platform_json_install

	unibuild_install_files arc-files "${WORKDIR}/project-config.json"
	unibuild_install_files thermal-files "${WORKDIR}/project-config.json"
	unibuild_install_touch_files "${WORKDIR}/project-config.json"
	unibuild_install_files intel-wifi-sar-files "${WORKDIR}/project-config.json"
}
