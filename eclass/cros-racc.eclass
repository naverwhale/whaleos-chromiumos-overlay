# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: cros-racc.eclass
# @BLURB: helper eclass for building Chromium packages of RACC
# @DESCRIPTION:
# Packages src/platform2/{hardware_verifier,runtime_probe} are in active
# development.  We have to add board-specific rules manually.

EXPORT_FUNCTIONS src_compile src_install

# @ECLASS-VARIABLE: CROS_RACC_MODEL
# @DESCRIPTION:
# Array of models to installed.
# TODO(b/169428818): Stop maintaining board-model mapping.
: "${CROS_RACC_MODEL:=}"

# @FUNCTION: cros-racc_src_compile
# @DESCRIPTION:
# Remove all indents, line breaks and spaces in json file to reduce disk usage.
cros-racc_src_compile() {
	einfo "cros-racc src_compile"

	local CMD_MINIFY_JSON=("jq" "-c" ".")
	local BUILD_ROOT="${WORKDIR}/build"
	local model
	for model in "${CROS_RACC_MODEL[@]}"; do
		local CONFIG="runtime_probe/${model}/probe_config.json"
		mkdir -p "$(dirname "${BUILD_ROOT}/${CONFIG}")"
		"${CMD_MINIFY_JSON[@]}" \
			< "${FILESDIR}/${CONFIG}" > "${BUILD_ROOT}/${CONFIG}" ||
			die "Failed to minify json file: ${CONFIG}"
	done
}

# @FUNCTION: cros-racc_src_install
# @DESCRIPTION:
# Install AVL runtime verification config files.
# https://bugs.chromium.org/p/chromium/issues/detail?id=959178 for more details.
cros-racc_src_install() {
	einfo "cros-racc src_install"

	local model
	for model in "${CROS_RACC_MODEL[@]}"; do
		insinto "/etc/runtime_probe/${model}"
		doins "${WORKDIR}/build/runtime_probe/${model}/probe_config.json"
	done

	insinto /etc/hardware_verifier
	doins "${FILESDIR}/hw_verification_spec.prototxt"
}
