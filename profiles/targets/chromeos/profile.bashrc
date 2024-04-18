# Copyright 2011 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Locate all the old style config scripts this package installs.  Do it here
# here so we can search the temp $D which has only this pkg rather than the
# full ROOT which has everyone's files.
cros_post_src_install_wrap_old_config_scripts() {
	# bashrc runs in ebuild context, so declare vars to make shellcheck happy.
	: "${D?}" "${CHOST?}" "${CROS_ADDONS_TREE?}"

	# Ignore $CHOST- prefix as some packages create that inaddition to the
	# unprefixed.
	local wrappers
	mapfile -d '' wrappers < <(
		find "${D}"/usr/bin/ \
			'!' -name "${CHOST}-*" -name '*-config' \
			-printf '%P\0' 2>/dev/null
	)

	dodir /build/bin

	local w
	for w in "${wrappers[@]}" ; do
		dosym "${CROS_ADDONS_TREE}/scripts/config_wrapper" \
			"/build/bin/${CHOST}-${w}"
	done
}
