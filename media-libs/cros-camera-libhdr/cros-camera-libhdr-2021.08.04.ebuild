# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Chrome OS HDR related libraries ported from google3."

IUSE="march_skylake march_alderlake"

SRC_URI="gs://chromeos-localmirror/distfiles/chromeos-camera-libhdr-${PV}.tar.bz2"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}"

src_install() {
	# march USE flag check should be put before amd64, arm, and arm64.
	local march_path
	if use march_skylake; then
		march_path="x86_64-skylake"
	elif use march_alderlake; then
		march_path="x86_64-alderlake"
	elif use amd64; then
		march_path="x86_64"
	fi
	einfo "Installing binaries built with march ${march_path}"

	local libraries=(
		"libhdrnet_cros.so"
		"libgcam_ae_cros.so"
	)
	for library in "${libraries[@]}"; do
		dolib.so "./${march_path}/${library}"
	done

	# Install header files.
	insinto /usr/include/cros-camera
	doins ./*.h
}
