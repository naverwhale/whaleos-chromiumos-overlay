# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# @ECLASS: modem-fw-dlc.eclass
# @MAINTAINER:
# cros-cellular-core@, andrewlassalle@chromium.org
# @BUGREPORTS:
# Please report bugs via
# https://issuetracker.google.com/issues/new?component=167157
# @VCSURL: https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay/+/HEAD/eclass/@ECLASS@
# @BLURB: helper eclass for building modem FW DLCs
# @DESCRIPTION:
# Common settings use by most modem FW DLCs.

if [[ -z "${_ECLASS_MODEM_FW_DLC}" ]]; then

# Multiple inclusion protection.
_ECLASS_MODEM_FW_DLC=1

inherit dlc estack

# @ECLASS-VARIABLE: MODEM_FW_DLC_PREALLOC_SIZE_MB
# @DEFAULT_UNSET
# @DESCRIPTION:
# The DLC size in MiB.
# This value can be used to define the DLC preallocatoin size in MiB instead of
# directly using DLC_PREALLOC_BLOCKS.

# @ECLASS-VARIABLE: MODEM_FW_DLC_FM101_DEFAULT_SIZE_3FW
# @INTERNAL
# @DESCRIPTION:
# The default preallocation size for FM101 modem DLCs.
# This value should never increase, since there is no guarantee that the user
# will have enough space left to accommodate the increase in size.
# We reserve enough space to fit:
# uncompressed => 3 Main FWs = ~89MiB * 3 =  267MiB
# compressed => 3 Main FWs = ~64MiB * 3 =  192MiB
# Total = ~192MiB => 200MiB to be safe
readonly MODEM_FW_DLC_FM101_DEFAULT_SIZE_3FW=200

# @ECLASS-VARIABLE: MODEM_FW_DLC_FM350_DEFAULT_SIZE_3FW
# @INTERNAL
# @DESCRIPTION:
# The default preallocation size for Fibocom FM350 modem DLCs.
# This value should never increase, since there is no guarantee that the user
# will have enough space left to accommodate the increase in size.
# We reserve enough space to fit:
# uncompressed => 3 Main FWs = ~77MiB * 3 =  231MiB
# compressed => 3 Main FWs = ~50MiB * 3 =  150MiB
# Total = ~150 MiB => 156MiB to be safe
readonly MODEM_FW_DLC_FM350_DEFAULT_SIZE_3FW=156

# @ECLASS-VARIABLE: MODEM_FW_DLC_L850_DEFAULT_SIZE_3FW
# @INTERNAL
# @DESCRIPTION:
# The default preallocation size for Fibocom L850 modem DLCs.
# This value should never increase, since there is no guarantee that the user
# will have enough space left to accommodate the increase in size.
# We reserve enough space to fit:
# 3 Main FWs = ~11MiB * 3 (All L850 files are already compressed)
# 1 OEM FW = 125KiB
# 1 OEM carrier pack = 2MiB
# Total = ~36 MiB => 39MiB to be safe
readonly MODEM_FW_DLC_L850_DEFAULT_SIZE_3FW=39

# @ECLASS-VARIABLE: MODEM_FW_DLC_EM060_DEFAULT_SIZE
# @INTERNAL
# @DESCRIPTION:
# The default preallocation size for Quectel EM060 modem DLCs.
# This value should never increase, since there is no guarantee that the user
# will have enough space left to accommodate the increase in size.
# We reserve enough space to fit:
# As per Quectel, the max size would be 180MiB
# Total = ~180 MiB => 300MiB to be safe
# TODO(b/307580737): Add math here when we have more details.
readonly MODEM_FW_DLC_EM060_DEFAULT_SIZE=300

# Installs the DLC during FSI.
DLC_FACTORY_INSTALL=true

# Preload on test images
DLC_PRELOAD=true

# Always update with the OS
DLC_CRITICAL_UPDATE=true

# Keep DLC on powerwash
DLC_POWERWASH_SAFE=true

# Trusted dm-verity digest through LoadPin.
DLC_LOADPIN_VERITY_DIGEST=true

# DLC will use logical volume. Needed for powerwash survival.
DLC_USE_LOGICAL_VOLUME=true

# @FUNCTION: modem_fw_dlc_src_install
# @DESCRIPTION:
# Convenience function to create a Modem FW DLC. The function does some basic
# validation, packages the modem FW files in the correct directories and
# creates the DLC.
modem_fw_dlc_src_install() {
	# Only set DLC_PREALLOC_BLOCKS if MODEM_FW_DLC_PREALLOC_SIZE_MB was set in the ebuild.
	# This allows for the use of either flag in the ebuild.
	if [[ -n "${MODEM_FW_DLC_PREALLOC_SIZE_MB}" ]]; then
		# 256 blocks = 1MiB/4Kib = 1024*1024/4096.
		DLC_PREALLOC_BLOCKS="$((MODEM_FW_DLC_PREALLOC_SIZE_MB * 256))"
	fi
	local modem modem_counter=0
	# Only add modems in which the directory name matches the substring of the tarball.
	# If that's not the case, add a separate logic for it.
	for modem in "fm350" "l850" "fm101" "em060"; do
		eshopts_push -s nullglob
		local modem_dirs=(cellular-firmware-{fibocom,quectel}-"${modem}"-*)
		eshopts_pop
		if [[ "${#modem_dirs[@]}" -ne 0 ]]; then
			# Modem FW DLCs should always contain FWs of 1 type of modem only,
			# since they are defined per variant.
			[[ "${modem_counter}" -eq 0 ]] || die "Multiple modem FWs found in DLC"
			insinto "$(dlc_add_path "/${modem}")"
			local f
			for f in "${modem_dirs[@]}"; do
				doins -r "${f}"/*
			done
			: $((modem_counter += 1))
		fi
	done

	dlc_src_install
}
fi
