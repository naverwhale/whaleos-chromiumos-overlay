# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Tools to obtain gerrit credentials from GCE."
HOMEPAGE="https://gerrit.googlesource.com/gcompute-tools"
GIT_SHA1="4e2fa665a0d8a20f12f57fecba56e3eccc7a199a"
SRC_URI="https://gerrit.googlesource.com/gcompute-tools/+archive/${GIT_SHA1}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="dev-lang/python"
DEPEND=""

S="${WORKDIR}"

src_install() {
	dobin git-googlesource-login git-cookie-authdaemon
}
