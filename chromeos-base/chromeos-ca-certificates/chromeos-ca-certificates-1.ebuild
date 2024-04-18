# Copyright 2010 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python3_{8..11} )

inherit python-any-r1

DESCRIPTION="Chrome OS restricted set of certificates"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/docs/+/HEAD/ca_certs.md"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

BDEPEND="
	${PYTHON_DEPS}
	app-misc/c_rehash
"

S=${WORKDIR}

src_compile() {
	"${FILESDIR}/split-root-certs.py" \
		--extract-to "${S}" \
		--roots-pem "${FILESDIR}/roots.pem" \
		|| die "Couldn't extract certs from roots.pem"
}

src_install() {
	CA_CERT_DIR=/usr/share/chromeos-ca-certificates
	insinto "${CA_CERT_DIR}"
	doins *.pem
	c_rehash "${D}/${CA_CERT_DIR}"
}
