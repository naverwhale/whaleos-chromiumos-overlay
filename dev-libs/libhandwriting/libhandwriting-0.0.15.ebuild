# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit dlc

DESCRIPTION="Google handwriting recognition library for Chrome OS"
HOMEPAGE="https://www.chromium.org/chromium-os"
SRC_URI="gs://chromeos-localmirror/distfiles/libhandwriting-${PV}.tar.gz"

LICENSE="BSD-Google Apache-2.0 MPL-2.0 icu-58"
SLOT="0"
KEYWORDS="*"

IUSE="ondevice_handwriting ondevice_handwriting_dlc dlc"

# ondevice_handwriting and ondevice_handwriting_dlc should be enabled at most
# one. And if ondevice_handwriting_dlc is enabled; dlc should also be enabled.
REQUIRED_USE="
	ondevice_handwriting_dlc? ( dlc )
	?? ( ondevice_handwriting ondevice_handwriting_dlc )"

S="${WORKDIR}"

# The storage space for this dlc. This sets up the upper limit of this dlc to be
# DLC_PREALLOC_BLOCKS * 4KB = 40MB for now.
DLC_PREALLOC_BLOCKS="10240"

src_install() {
	insinto /usr/include/chromeos/libhandwriting/
	doins handwriting_interface.h
	insinto /usr/include/chromeos/libhandwriting/proto/
	doins handwriting_interface.proto
	sed -i 's!chrome/knowledge/handwriting/!!g' handwriting_validate.proto || die
	doins handwriting_validate.proto

	if ! use ondevice_handwriting && ! use ondevice_handwriting_dlc; then
		return
	fi

	if use ondevice_handwriting; then
		local handwritinglib_path="/opt/google/chrome/ml_models/handwriting/"
	else
		local handwritinglib_path="$(dlc_add_path /)"
	fi

	insinto "${handwritinglib_path}"
	# Install the shared library.
	insopts -m0755
	newins "libhandwriting-${ARCH}.so" "libhandwriting.so"
	insopts -m0644
	# Install the model files for english.
	doins latin_indy.compact.fst latin_indy.pb latin_indy.tflite
	doins latin_indy_conf.tflite latin_indy_seg.tflite
	# Install the model files for gesture recognition.
	newins gic20190510.tflite gic.reco_model.tflite
	newins gic20190510_cros.ondevice.recospec.pb gic.recospec.pb

	# Run dlc_src_install.
	if use ondevice_handwriting_dlc; then
		dlc_src_install
	fi

	# Only enable the tests for ondevice_handwriting.
	if use ondevice_handwriting; then
		# Install the testing data.
		insinto /build/share/libhandwriting/
		doins handwriting_labeled_requests.pb
		doins gesture_labeled_requests.pb
	fi
}
