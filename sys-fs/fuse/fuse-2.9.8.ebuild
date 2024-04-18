# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit libtool udev fcaps autotools

DESCRIPTION="An interface for filesystems implemented in userspace"
HOMEPAGE="https://github.com/libfuse/libfuse"
SRC_URI="https://github.com/libfuse/libfuse/releases/download/${P}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="examples kernel_linux kernel_FreeBSD static-libs"

PDEPEND="kernel_FreeBSD? ( sys-fs/fuse4bsd )"
DEPEND="virtual/pkgconfig"
RDEPEND="sys-fs/fuse-common"

src_prepare() {
	local PATCHES=(
		"${FILESDIR}"/${PN}-2.8.5-fix-lazy-binding.patch
		"${FILESDIR}"/${PN}-2.8.5-gold.patch
		"${FILESDIR}"/${PN}-2.8.6-remove-setuid.patch
		"${FILESDIR}"/${PN}-2.9.3-kernel-types.patch
		"${FILESDIR}"/${PN}-2.9.7-pass-fuse-fd.patch
		"${FILESDIR}"/${PN}-2.9.8-user-option.patch
		"${FILESDIR}"/${PN}-2.9.9-closefrom-glibc-2-34.patch
	)
	# sandbox violation with mtab writability wrt #438250
	sed -i 's:umount --fake:true --fake:' configure.ac || die

	default

	eautoreconf
	elibtoolize
}

src_configure() {
	econf \
		INIT_D_PATH="${EPREFIX}/etc/init.d" \
		MOUNT_FUSE_PATH="${EPREFIX}/sbin" \
		UDEV_RULES_PATH="${EPREFIX}/$(get_udevdir)/rules.d" \
		$(use_enable static-libs static) \
		--disable-example
}

src_install() {
	local DOCS=( AUTHORS ChangeLog README.md README.NFS NEWS doc/how-fuse-works doc/kernel.txt )
	default

	if use examples ; then
		docinto examples
		dodoc example/*
	fi

	if use kernel_FreeBSD ; then
		insinto /usr/include/fuse
		doins include/fuse_kernel.h
	fi

	use static-libs || find "${ED}" -name '*.la' -delete

	# installed via fuse-common
	rm -r "${ED}"/{etc,"$(get_udevdir)"} || die
	rm "${ED}"/usr/share/man/man8/mount.fuse.* || die
	rm "${ED}"/sbin/mount.fuse || die

	# handled by the device manager
	rm -r "${D}"/dev || die
}

pkg_postinst() {
	# CHROMIUM: remove-setuid.patch removes suid. Add fcaps instead.
	fcaps cap_sys_admin usr/bin/fusermount
}
