# Copyright 2018 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

cros_pre_src_configure_dhcp_config() {
  EXTRA_ECONF+=" --with-randomdev=/dev/urandom "
}
