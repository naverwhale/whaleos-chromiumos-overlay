# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# TODO(b/299351358) OpenSSL 3 dropped the ERR_GET_FUNC, FIPS_mode, and
# FIPS_mode_set symbols.
#
# Drop this hack once we upgrade to >=cryptography-41.0.3.
cros_post_src_prepare_openssl3_patch() {
  # shellcheck disable=SC2154
  sed -i -e '/int ERR_GET_FUNC(unsigned long);/d' "${S}/src/_cffi_src/openssl/err.py" || die
  # shellcheck disable=SC2154
  sed -i -e '/int FIPS_mode(void);/d' -e '/int FIPS_mode_set(int);/d' "${S}/src/_cffi_src/openssl/fips.py" || die
  # shellcheck disable=SC2154
  sed -i -e 's/lib.ERR_GET_FUNC(code)/"nullptr"/g' "${S}/src/cryptography/hazmat/bindings/openssl/binding.py" || die
}
