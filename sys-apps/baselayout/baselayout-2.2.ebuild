# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit multilib

DESCRIPTION="Filesystem baselayout and init scripts (Modified for Chromium OS)"
HOMEPAGE="http://src.chromium.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2
	http://dev.gentoo.org/~vapier/dist/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="+auto_seed_etc_files kvm_host"

PATCHES=(
	"${FILESDIR}"/add-dash-shell.patch
)

src_install() {
	emake \
		OS=$(usex kernel_FreeBSD BSD Linux) \
		DESTDIR="${D}" \
		install

	# handle multilib paths.  do it here because we want this behavior
	# regardless of the C library that you're using.  we do explicitly
	# list paths which the native ldconfig searches, but this isn't
	# problematic as it doesn't change the resulting ld.so.cache or
	# take longer to generate.  similarly, listing both the native
	# path and the symlinked path doesn't change the resulting cache.
	local libdir ldpaths
	for libdir in $(get_all_libdirs) ; do
		ldpaths+=":/${libdir}:/usr/${libdir}:/usr/local/${libdir}"
	done
	sed -i -e '/^LDPATH/d' "${D}"/etc/env.d/00basic || die
	echo "LDPATH='${ldpaths#:}'" >> "${D}"/etc/env.d/00basic

	# Remove files that don't make sense for Chromium OS
	for x in issue issue.logo os-release; do
		rm -f "${D}/etc/${x}"
	done

	if use kvm_host ; then
		# Set up the dir for where we will symlink /etc/hosts.
		dodir /etc/hosts.d
	fi

	# This file has moved to openrc, but we don't want that.
	# https://bugs.gentoo.org/373219
	insinto /etc/init.d
	doins "${FILESDIR}"/functions.sh
}

pkg_postinst() {
	local x

	# We installed some files to /usr/share/baselayout instead of /etc to stop
	# (1) overwriting the user's settings
	# (2) screwing things up when attempting to merge files
	# (3) accidentally packaging up personal files with quickpkg
	# If they don't exist then we install them
	for x in master.passwd passwd shadow group fstab ; do
		if use auto_seed_etc_files ; then
			[ -e "${EROOT}/etc/${x}" ] && continue
			[ -e "${EROOT}/usr/share/baselayout/${x}" ] || continue
			cp -p "${EROOT}/usr/share/baselayout/${x}" "${EROOT}"/etc || die
		else
			touch "${EROOT}/etc/${x}" && continue
		fi
	done

	# Force shadow permissions to not be world-readable #260993
	for x in shadow ; do
		if [ -e "${EROOT}/etc/${x}" ] ; then
			chmod o-rwx "${EROOT}/etc/${x}" || die
		fi
	done

	if use kvm_host ; then
		# Set up the symlinked /etc/hosts file by moving the existing one into
		# /etc/hosts.d and then symlinking to it from /etc/hosts.
		mv "${EROOT}/etc/hosts" "${EROOT}/etc/hosts.d/hosts"
		ln -s /etc/hosts.d/hosts "${EROOT}/etc/hosts"
	fi
}
