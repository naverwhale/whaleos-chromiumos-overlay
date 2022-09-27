# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_BOARDS=( none )

inherit cros-config-test

DESCRIPTION="Package for Chrome OS cros config tast test configuration."
HOMEPAGE="https://www.chromium.org"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	virtual/chromeos-bsp-test
	chromeos-base/tast-local-tests-cros
"
RDEPEND="${DEPEND}"

# There is no workon source directory, so use the work directory.
S=${WORKDIR}

src_install() {
	# Input file is in the build directory in the CROS_CONFIG_TEST_DIR.
	local device_cmds_yaml="cros_config_device_commands.yaml"
	local common_cmds_yaml="cros_config_test_common.yaml"
	local device_input_dir="${SYSROOT}${CROS_CONFIG_TEST_DIR}/tast"
	local device_input_file="${device_input_dir}/${device_cmds_yaml}"

	if [[ -e "${device_input_file}" ]]; then
		local tast_device_file="${WORKDIR}/${device_cmds_yaml}"
		local tast_output_file="${WORKDIR}/cros_config_test_commands.json"

		# Copy the common and device specific commands yaml to the workdir so they can be merged and transformed.
		cp "${FILESDIR}/${common_cmds_yaml}" "${WORKDIR}/${common_cmds_yaml}"
		cp "${device_input_file}" "${tast_device_file}"

		# Merge and transform the input YAML files to the JSON output that will be the input to the TAST Golang program.
		cros_config_test_schema -c "${tast_device_file}" -o "${tast_output_file}" || die "cros_config_test_schema failed"

		# Created a commands json file, install all of the commands and golden JSON files.
		local tast_output_dir="${CROS_CONFIG_TEST_DIR}/tast"
		einfo "Installing ${tast_output_file} into ${tast_output_dir}"
		insinto "${CROS_CONFIG_TEST_DIR}/tast"
		doins cros_config_test_commands.json

		# Install all of the golden files from the golden temp directory.
		# TOOD(gmeinke): refactor this code to use cros-unibuild.eclass _find_config but renamed
		# because it really has nothing to do with finding configs.
		while read -d $'\0' -r file; do
			einfo "Installing golden file ${file}"
			newins "${file}" "$(basename ${file})"
		done < <(find "${device_input_dir}/golden/" -name "*_golden_file.json" -print0)
	fi
}
