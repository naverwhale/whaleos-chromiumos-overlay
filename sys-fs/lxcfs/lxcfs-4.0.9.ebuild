# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# TODO(crbug.com/1097610) Once stabilized, this can go back to
# portage-stable

EAPI=7

inherit autotools systemd verify-sig

DESCRIPTION="FUSE filesystem for LXC"
HOMEPAGE="https://linuxcontainers.org/lxcfs/introduction/ https://github.com/lxc/lxcfs/"
SRC_URI="https://linuxcontainers.org/downloads/lxcfs/${P}.tar.gz
	verify-sig? ( https://linuxcontainers.org/downloads/lxcfs/${P}.tar.gz.asc )"

LICENSE="Apache-2.0"
SLOT="4"
KEYWORDS="*"

# TODO(crbug.com/1097610) Upstream gentoo has lxcfs depending on fuse:3, but the
# actual configure script prefers fuse:0. This saves us from having to update
# fuse at least.
RDEPEND="dev-libs/glib:2
	sys-fs/fuse:0"
DEPEND="${RDEPEND}"
BDEPEND="sys-apps/help2man
	verify-sig? ( app-crypt/openpgp-keys-linuxcontainers )"

# Test files need to be updated to fuse:3, #764620
RESTRICT="test"

VERIFY_SIG_OPENPGP_KEY_PATH=${BROOT}/usr/share/openpgp-keys/linuxcontainers.asc

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	# Without the localstatedir the filesystem isn't mounted correctly
	# Without with-distro ./configure will fail when cross-compiling
	econf --localstatedir=/var --with-distro=gentoo --disable-static \
		--prefix="${EPREFIX}"/opt/google/lxd-next
}

src_test() {
	cd tests/ || die
	emake tests
	./main.sh || die "Tests failed"
}

src_install() {
	default

	newconfd "${FILESDIR}"/lxcfs-4.0.0.confd lxcfs
	newinitd "${FILESDIR}"/lxcfs-4.0.0.initd lxcfs

	find "${ED}" -name '*.la' -delete || die
}
