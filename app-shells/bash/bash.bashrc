# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

cros_pre_src_prepare_patches() {
  # Not using ${P} to refer to patch to avoid updating it on every _p# change.
	eapply "${BASHRC_FILESDIR}"/${PN}-4.4-noexec.patch || die

	# Disable this logic for SDK builds.
	if [[ $(cros_target) == "cros_host" ]]; then
		CPPFLAGS+=" -DSHELL_IGNORE_NOEXEC"
	else
		# Emit crash reports when we detect problems.
		CPPFLAGS+=" -DSHELL_NOEXEC_CRASH_REPORTS"
		# Don't halt execution for now.
		# TODO(vapier): Remove this once crash report rates go down.
		CPPFLAGS+=" -DSHELL_NOEXEC_REPORT_ONLY"
	fi
	export CPPFLAGS
}
