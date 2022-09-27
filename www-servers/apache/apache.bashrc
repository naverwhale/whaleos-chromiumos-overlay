# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# The apache ebuild & configure script will search $PATH for these config
# scripts.  Link the ones from the sysroot into a dir so apache can find
# them and get details out of them.  These are shell scripts, so it's safe.
cros_pre_src_configure_hack_apr_config() {
	mkdir -p "${T}/bin"
	ln -s "${SYSROOT}/usr/bin/apr-1-config" "${T}/bin/" || die
	ln -s "${SYSROOT}/usr/bin/apu-1-config" "${T}/bin/" || die
	export PATH="${T}/bin:${PATH}"
}
