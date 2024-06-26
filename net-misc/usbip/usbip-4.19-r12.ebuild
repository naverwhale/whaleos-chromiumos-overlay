# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT="3bdb80898fa79e7c62747cea1908557ce3adc519"
CROS_WORKON_TREE="f3a0a0009d4cfe0cd2783cefc1c92f3c79fef691"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/v4.19"
CROS_WORKON_EGIT_BRANCH="chromeos-4.19"
CROS_WORKON_SUBTREE="tools/usb/usbip"

inherit autotools cros-workon cros-sanitizers

DESCRIPTION="Userspace utilities for a general USB device sharing system over IP networks"
HOMEPAGE="https://www.kernel.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs tcpd"

RDEPEND=">=dev-libs/glib-2.6
	sys-apps/hwdata
	virtual/libudev:=
	tcpd? ( sys-apps/tcp-wrappers )"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

DOCS="AUTHORS README"

S=${WORKDIR}/linux-${PV}/tools/usb/${PN}

src_unpack() {
	cros-workon_src_unpack
	S+="/tools/usb/usbip"
}

src_prepare() {
	# remove -Werror from build, bug #545398
	sed -i 's/-Werror[^ ]* //g' configure.ac || die

	default

	eautoreconf
}

src_configure() {
	sanitizers-setup-env

	econf \
		$(use_enable static-libs static) \
		"$(use_with tcpd tcp-wrappers)" \
		--with-usbids-dir=/usr/share/hwdata
}

src_install() {
	default
	if ! use static-libs; then
		rm "${ED}"/usr/lib*/*.la || die
	fi
}
