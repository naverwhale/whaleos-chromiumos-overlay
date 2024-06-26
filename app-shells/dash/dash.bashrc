# Copyright 2017 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Filter sanitizer flags from dash, https://crbug.com/950356.
cros_pre_src_prepare_filter_sanitizers() {
	filter_sanitizers
}

cros_pre_src_prepare_patches() {
	# shellcheck disable=SC2154
	eapply "${BASHRC_FILESDIR}/${PN}-0.5.12-noexec.patch" || die

	# Disable this logic for SDK builds.
	if [[ $(cros_target) == "cros_host" ]]; then
		CPPFLAGS+=" -DSHELL_IGNORE_NOEXEC"
	else
		# Emit crash reports when we detect problems.
		CPPFLAGS+=" -DSHELL_NOEXEC_CRASH_REPORTS"
	fi
	export CPPFLAGS
}

cros_pre_src_configure_lfs() {
	export CPPFLAGS+=" -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE "
}
