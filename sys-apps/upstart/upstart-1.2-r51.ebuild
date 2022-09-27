# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT="7a9bc4fbe5897a8b7f52218f4236bb3af604445b"
CROS_WORKON_TREE="4d503ec7163213da41c0beb5ea4573493fae2582"
CROS_WORKON_PROJECT="chromiumos/third_party/upstart"
CROS_WORKON_LOCALNAME="../third_party/upstart"
CROS_WORKON_EGIT_BRANCH="chromeos-1.2"

inherit cros-workon autotools flag-o-matic

DESCRIPTION="An event-based replacement for the init daemon"
HOMEPAGE="http://upstart.ubuntu.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="debug direncryption examples global_seccomp manatee nls selinux udev_bridge"

RDEPEND=">=sys-apps/dbus-1.2.16
	>=sys-libs/libnih-1.0.2
	selinux? (
		sys-libs/libselinux
		sys-libs/libsepol
	)
	udev_bridge? (
		>=virtual/libudev-146
	)
	direncryption? (
		sys-apps/keyutils
	)
	global_seccomp? (
		chromeos-base/minijail
	)"
DEPEND=">=dev-libs/expat-2.0.0
	nls? ( sys-devel/gettext )
	direncryption? (
		sys-fs/e2fsprogs
	)
	${RDEPEND}"
RDEPEND+="
	selinux? ( chromeos-base/selinux-policy )"

src_prepare() {
	default

	# Patch to use kmsg at higher verbosity for logging; this is
	# our own patch because we can't just add --verbose to the
	# kernel command-line when we need to.
	use debug && eapply "${FILESDIR}"/upstart-1.2-log-verbosity.patch

	# The selinux patch changes makefile.am and configure.ac
	# so we need to run autoreconf, and if we don't the system
	# will do it for us, and incorrectly too.
	eautoreconf
}

src_configure() {
	# Rearrange PATH so that /usr/local does not override /usr.
	append-cppflags '-DPATH="\"/usr/bin:/usr/sbin:/sbin:/bin:/usr/local/sbin:/usr/local/bin\""'

	append-lfs-flags

	local myconf=(
		--prefix=/
		--exec-prefix=
		--includedir="${prefix}/usr/include"
		--disable-rpath
		$(use_with direncryption dircrypto-keyring)
		$(use_enable selinux)
		$(use_enable nls)
		$(use_enable manatee)
	)

	if use global_seccomp; then
		myconf+=(
			--with-seccomp-constants="${SYSROOT}/build/share/constants.json"
		)
	fi

	econf "${myconf[@]}"
}

src_compile() {
	emake clean
	emake "NIH_DBUS_TOOL=$(which nih-dbus-tool)"
}

src_install() {
	default
	use examples || rm "${D}"/etc/init/*.conf
	insinto /etc/init
	# Always use our own upstart-socket-bridge.conf.
	doins "${FILESDIR}"/init/upstart-socket-bridge.conf
	# Restore udev bridge if requested.
	use udev_bridge && doins extra/conf/upstart-udev-bridge.conf
	# Install D-Bus XML files.
	insinto /usr/share/dbus-1/interfaces/
	doins "${S}"/dbus/*.xml
}
