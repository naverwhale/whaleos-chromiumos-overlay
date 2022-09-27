# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

cros_pre_src_configure_xopensource() {
	# Workaround to build qemu 5.2 with ncurses 5.
	# ncurses 6 does not appear to need it.
	append-cppflags "-D_XOPEN_SOURCE_EXTENDED"
}

cros_post_src_install_lddtree() {
	# Create a package we can use outside the SDK.
	# Only do this for the few tools we use for chromite.lib.vm.
	local prog progs=( qemu-img qemu-system-x86_64 )
	/mnt/host/source/chromite/bin/lddtree \
		--copy-to "${D}/usr/libexec/qemu" \
		--libdir /lib \
		--bindir /bin \
		--generate-wrappers \
		"${progs[@]/#/${D}/usr/bin/}" || die
	# glibc dynamically loads these based on /etc/nsswich.conf, so we have
	# to copy them over manually.
	cp "${SYSROOT}/$(get_libdir)/libnss_"{compat,db,dns,files}.so.2 \
		"${D}/usr/libexec/qemu/lib/" || die
	# No need to duplicate this in the package itself.
	for prog in "${progs[@]}"; do
		dosym ../../../bin/"${prog}" /usr/libexec/qemu/bin/"${prog}".elf
	done
	# QEMU searches for its bios files relative to itself.  Add a symlink so it
	# can find the installed bios files under /usr/share/qemu/.
	dosym ../../share/qemu /usr/libexec/qemu/pc-bios
	dosym ../../share /usr/libexec/qemu/share
}
