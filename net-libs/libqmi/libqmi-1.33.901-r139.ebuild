# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
CROS_WORKON_COMMIT="4bf50d2e88748b7eac82ee9afd9c6fad0dc71dde"
CROS_WORKON_TREE="ca0a4cf7507618e91172cb35cdeeb8704810a296"
CROS_WORKON_PROJECT="chromiumos/third_party/libqmi"

inherit meson cros-sanitizers cros-workon udev cros-fuzzer cros-sanitizers

DESCRIPTION="QMI modem protocol helper library"
HOMEPAGE="http://cgit.freedesktop.org/libqmi/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="-asan mbim qrtr fuzzer"

RDEPEND=">=dev-libs/glib-2.36
	>=net-libs/libmbim-1.18.0
	net-libs/libqrtr-glib"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_configure() {
	sanitizers-setup-env

	append-cppflags -DQMI_DISABLE_DEPRECATED

	local emesonargs=(
		--prefix='/usr'
		-Dqmi_username='modem'
		-Dlibexecdir='/usr/libexec'
		-Dudevdir='/lib/udev'
		-Dintrospection=false
		-Dman=false
		-Dbash_completion=false
		-Dudev=false
		-Dfirmware_update=false
		$(meson_use fuzzer)
	)
	meson_src_configure
}

src_install() {
	meson_src_install

	if use fuzzer; then
		local fuzzer_build_path="${BUILD_DIR}/src/libqmi-glib/test"
		cp "${fuzzer_build_path}/test-message-fuzzer" \
			"${fuzzer_build_path}/test-qmi-message-fuzzer" || die

		# ChromeOS/Platform/Connectivity/Cellular
		local fuzzer_component_id="167157"
		fuzzer_install "${S}/OWNERS" \
			"${fuzzer_build_path}/test-qmi-message-fuzzer" \
			--comp "${fuzzer_component_id}"
	fi
}
