# Copyright 2014 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI="4"

DESCRIPTION="Install Chromium OS ssh test keys to a shared location."
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}"

IUSE="-generated_ssh_key"
KEYSDIR="${FILESDIR}"

generate_key_pair() {
	einfo "Generating ssh key pair in ${S} ..."
	ssh-keygen -t rsa -b 4096 -C "ChromeOS test key" -N "" \
		-f "${S}"/testing_rsa
	KEYSDIR="${S}"
}

src_compile() {
	use generated_ssh_key && generate_key_pair
}

src_install() {
	local install_dir=/usr/share/chromeos-ssh-config/keys

	# Create authorized_keys file using all public keys
	dodir "${install_dir}"
	cat "${KEYSDIR}"/*.pub > "${D}"/"${install_dir}"/authorized_keys || die

	# Install the SSH key files
	insinto "${install_dir}"
	newins "${KEYSDIR}"/testing_rsa id_rsa
	newins "${KEYSDIR}"/testing_rsa.pub id_rsa.pub
	fperms 600 "${install_dir}"/id_rsa
}
