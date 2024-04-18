# Copyright 2014 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# These OpenSSL programs are for debugging only and should not be required in
# the image. CA.pl and tsget also require perl, which is normally not available
# in the image.
if [[ $(cros_target) != "cros_host" ]]; then
  openssl_mask="
    /etc/ssl/misc/CA.pl
    /etc/ssl/misc/CA.sh
    /etc/ssl/misc/c_hash
    /etc/ssl/misc/c_info
    /etc/ssl/misc/c_issuer
    /etc/ssl/misc/c_name
    /etc/ssl/misc/tsget
  "
  PKG_INSTALL_MASK+=" ${openssl_mask}"
  INSTALL_MASK+=" ${openssl_mask}"
  unset openssl_mask
fi

cros_post_src_prepare_patches() {
	eapply "${BASHRC_FILESDIR}"/${PN}-1.1.1j-blocklist.patch
	eapply "${BASHRC_FILESDIR}"/${PN}-1.1.1j-chromium-compatibility.patch

	if [[ "${PV}" == "3."* ]] ; then
		# TODO(b/297176773) Remove this after usage of deprecated APIs
		# is cleaned up.
		#
		# We don't want the deprecated declarations.
		sed -i '/# pragma once/a #define OPENSSL_SUPPRESS_DEPRECATED' "${S}/include/openssl/macros.h" || die
	fi
}

cros_pre_src_configure_cros_flags() {
	# ChromeOS-specific configuration.
	cros_optimize_package_for_speed
	append-lfs-flags
}

cros_pre_src_compile_patches() {
	no_libatomic() {
		# Do not link libatomic.
		einfo "PATCHING ${BUILD_DIR}/Makefile"
		sed -i 's/ -latomic//g' "${BUILD_DIR}/Makefile" || die
	}
	multilib_foreach_abi no_libatomic
}

cros_post_src_install_cros_files() {
	if [[ "${SLOT}" == "0"* ]] ; then
		# ChromeOS-specific files.
		insinto /etc/ssl
		doins "${BASHRC_FILESDIR}"/openssl.cnf.compat
		doins "${BASHRC_FILESDIR}"/blocklist
	fi
}
