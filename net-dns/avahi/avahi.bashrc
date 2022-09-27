# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

cros_post_src_install_avahi_nls() {
	# Even if we build w/USE=-nls, avahi forces it back on when glib is
	# enabled.  Forcibly punt the translations since we never use them.
	rm -rf "${D}"/usr/share/locale
}
