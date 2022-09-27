# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Google text suggestions library for Chrome OS"
HOMEPAGE="https://www.chromium.org/chromium-os"

LICENSE="BSD-Google"
SLOT="0"

SRC_URI="gs://chromeos-localmirror/distfiles/libsuggest-${PV}.tar.gz"
KEYWORDS="*"

IUSE="ondevice_text_suggestions"

S="${WORKDIR}"

src_install() {
	# Always install the header and proto files.
	insinto /usr/include/chromeos/libsuggest/
	doins text_suggester_interface.h
	insinto /usr/include/chromeos/libsuggest/proto/
	doins text_suggester_interface.proto

	if use ondevice_text_suggestions; then
		insinto /opt/google/chrome/ml_models/suggest/
		# Install shared lib
		insopts -m0755
		newins "libsuggest-${ARCH}.so" "libsuggest.so"
		insopts -m0644
		# Install the model artifacts.
		doins nwp.uint8.mmap.tflite
		doins nwp.csym
	fi
}
