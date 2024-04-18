# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7
CROS_WORKON_COMMIT="b200a3d693c3a32d81afd55136b2da04907cad96"
CROS_WORKON_TREE="4b5238292c7b5c9c1eafab4b8ba937231ed087b4"
CROS_WORKON_PROJECT="chromiumos/third_party/linux-firmware"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_EGIT_BRANCH="master"
CROS_WORKON_LOCALNAME="linux-firmware"

inherit cros-workon

DESCRIPTION="Firmware images from the upstream linux-firmware repo that are
built into the kernel binary"

KEYWORDS="*"

RDEPEND="!<sys-kernel/linux-firmware-0.0.1-r708"

LICENSE="
	builtin_fw_amdgpu_carrizo? ( LICENSE.amdgpu )
	builtin_fw_amdgpu_dimgrey_cavefish? ( LICENSE.amdgpu )
	builtin_fw_amdgpu_gc_10_3_7? ( LICENSE.amdgpu )
	builtin_fw_amdgpu_gc_11_0_1? ( LICENSE.amdgpu )
	builtin_fw_amdgpu_gc_11_0_4? ( LICENSE.amdgpu )
	builtin_fw_amdgpu_green_sardine? ( LICENSE.amdgpu )
	builtin_fw_amdgpu_navy_flounder? ( LICENSE.amdgpu )
	builtin_fw_amdgpu_picasso? ( LICENSE.amdgpu )
	builtin_fw_amdgpu_raven2? ( LICENSE.amdgpu )
	builtin_fw_amdgpu_renoir? ( LICENSE.amdgpu )
	builtin_fw_amdgpu_sienna_cichlid? ( LICENSE.amdgpu )
	builtin_fw_amdgpu_stoney? ( LICENSE.amdgpu )
	builtin_fw_amdgpu_vega12? ( LICENSE.amdgpu )
	builtin_fw_amdgpu_yellow_carp? ( LICENSE.amdgpu )
	builtin_fw_intel_mtl_i915? ( LICENSE.i915 )
"

FIRMWARE_INSTALL_ROOT="/lib/firmware"

IUSE_BUILTIN_FIRMWARE=(
	amdgpu_carrizo
	amdgpu_dimgrey_cavefish
	amdgpu_gc_10_3_7
	amdgpu_gc_11_0_1
	amdgpu_gc_11_0_4
	amdgpu_green_sardine
	amdgpu_navy_flounder
	amdgpu_picasso
	amdgpu_raven2
	amdgpu_renoir
	amdgpu_sienna_cichlid
	amdgpu_stoney
	amdgpu_vega12
	amdgpu_yellow_carp
	intel_mtl_i915
)

IUSE="${IUSE_BUILTIN_FIRMWARE[*]/#/builtin_fw_}"

use_builtin_fw() {
	use "builtin_fw_$1"
}

doins_subdir() {
	local file
	for file in "${@}"; do
		(
		insinto "${FIRMWARE_INSTALL_ROOT}/${file%/*}"
		doins "${file}"
		)
	done
}

install_amdgpu() {
	if use_builtin_fw amdgpu_carrizo; then
		doins_subdir amdgpu/carrizo*
	fi

	if use_builtin_fw amdgpu_dimgrey_cavefish; then
		doins_subdir amdgpu/dimgrey_cavefish*
	fi

	if use_builtin_fw amdgpu_gc_10_3_7; then
		doins_subdir amdgpu/dcn_3_1_6*
		doins_subdir amdgpu/gc_10_3_7_*
		doins_subdir amdgpu/psp_13_0_8_*
		doins_subdir amdgpu/sdma_5_2_7*
		doins_subdir amdgpu/yellow_carp_vcn.bin
	fi

	if use_builtin_fw amdgpu_gc_11_0_1; then
		doins_subdir amdgpu/dcn_3_1_4*
		doins_subdir amdgpu/gc_11_0_1_*
		doins_subdir amdgpu/psp_13_0_4_*
		doins_subdir amdgpu/sdma_6_0_1*
		doins_subdir amdgpu/vcn_4_0_2.bin
	fi

	if use_builtin_fw amdgpu_gc_11_0_4; then
		doins_subdir amdgpu/gc_11_0_4_*
		doins_subdir amdgpu/psp_13_0_11_*
	fi

	if use_builtin_fw amdgpu_green_sardine; then
		doins_subdir amdgpu/green_sardine*
	fi

	if use_builtin_fw amdgpu_navy_flounder; then
		doins_subdir amdgpu/navy_flounder*
	fi

	if use_builtin_fw amdgpu_picasso; then
		doins_subdir amdgpu/picasso*
	fi

	if use_builtin_fw amdgpu_raven2; then
		doins_subdir amdgpu/raven_dmcu*
		doins_subdir amdgpu/raven2*
	fi

	if use_builtin_fw amdgpu_renoir; then
		doins_subdir amdgpu/renoir*
	fi

	if use_builtin_fw amdgpu_sienna_cichlid; then
		doins_subdir amdgpu/sienna_cichlid*
	fi

	if use_builtin_fw amdgpu_stoney; then
		doins_subdir amdgpu/stoney*
	fi

	if use_builtin_fw amdgpu_vega12; then
		doins_subdir amdgpu/vega12*
	fi

	if use_builtin_fw amdgpu_yellow_carp; then
		doins_subdir amdgpu/yellow_carp*
	fi
}

install_intel_firmwares() {
	if use_builtin_fw intel_mtl_i915; then
		doins_subdir i915/mtl*
	fi
}

src_install() {
	install_amdgpu
	install_intel_firmwares
}
