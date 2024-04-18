# Copyright 2023 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit cmake cros-cellular

DESCRIPTION="EM060 firmware flashing tool"
HOMEPAGE="https://github.com/quectel-official/QModemHelper"
GIT_SHA1="5b3e0abdbe77bda72d58883c82fada8f4b3efcc0"
SRC_URI="https://github.com/quectel-official/QModemHelper/archive/${GIT_SHA1}.tar.gz -> QModemHelper-${GIT_SHA1}.tar.gz"


LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="dev-libs/libxml2:=
	net-misc/modemmanager-next:="

DEPEND="${RDEPEND}"

S="${WORKDIR}/QModemHelper-${GIT_SHA1}"

src_install() {
	cellular_dohelper "${BUILD_DIR}/bin/qmodemhelper"

	# Install helper seccomp policy
	insinto /usr/share/policy
	newins "${FILESDIR}/${PN}-seccomp-${ARCH}.policy" "${PN}-seccomp.policy"
}
