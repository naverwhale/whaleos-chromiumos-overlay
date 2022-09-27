# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: libchrome-version.eclass
# @MAINTAINER:
# ChromiumOS Build Team
# @BUGREPORTS:
# Please report bugs via http://crbug.com/new (with label Build)
# @VCSURL: https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay/+/master/eclass/@ECLASS@
# @BLURB: helper eclass for managing libchrome version
# @DESCRIPTION:
# This eclass manages the libchrome version.

# @FUNCTION: libchrome_ver
# @DESCRIPTION:
# Output current libchrome BASE_VER, from SYSROOT-installed BASE_VER file.
# IS_LIBCHROME or LIBCHROME_SYSROOT can be set.
# If IS_LIBCHROME is set, it read ${S}/BASE_VER instead.
# If LIBCHROME_SYSROOT is set, it read $LIBCHROME_SYSROOT-installed BASE_VER
# file.
libchrome_ver() {
	local basever_file="${SYSROOT}/usr/share/libchrome/BASE_VER"
	if [[ -n "${IS_LIBCHROME}" ]]; then
		basever_file="${S}/BASE_VER"
	fi
	if [[ -n "${LIBCHROME_SYSROOT}" ]]; then
		basever_file="${LIBCHROME_SYSROOT}/usr/share/libchrome/BASE_VER"
	fi
	cat "${basever_file}" || die "cat ${basever_file} error. Please depends on libchrome if you use it."
}
