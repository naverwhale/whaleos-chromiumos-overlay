# Copyright 2014 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

cros_pre_src_prepare_enable_cxx_exceptions() {
	cros_enable_cxx_exceptions
}

# Force matplotlib to use -j1 since it won't work otherwise.
# See: https://bugs.gentoo.org/699966#c9.

cros_pre_src_compile_matplotlib_serial() {
	export MAKEOPTS+=" -j1"
}
