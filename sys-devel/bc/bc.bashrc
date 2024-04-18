# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

cros_pre_src_prepare_patches() {
	# Add --sandbox option to disable access to files and system().
	# shellcheck disable=SC2154
	eapply "${BASHRC_FILESDIR}/${PN}-1.07.1-sandbox.patch" || die
}
