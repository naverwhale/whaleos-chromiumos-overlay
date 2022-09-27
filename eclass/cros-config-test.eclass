# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Check for EAPI 5+
case "${EAPI:-0}" in
[0-4]*) die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
esac

inherit cros-unibuild

# @FUNCTION: install_cros_config_test_files
# @USAGE:
# @DESCRIPTION:
# Installs all .json and .yaml tast test files for the current board.
# The files will be copied to the ${CROS_CONFIG_TEST_DIR}.
install_cros_config_test_files() {
	[[ $# -eq 0 ]] || die "${FUNCNAME}: takes no arguments"

	local output_dir="${CROS_CONFIG_TEST_DIR}/tast"
	local files=()
	# Copy all of the tast command YAML files.
	_find_configs "${FILESDIR}/../tast_files" ".yaml"
	_insert_config_files "${files[*]}" "${output_dir}" ""

	files=()
	# Copy all of the tast golden JSON files to golden dir.
	_find_configs "${FILESDIR}/../tast_files" ".json"
	_insert_config_files "${files[*]}" "${output_dir}/golden" ""
}
