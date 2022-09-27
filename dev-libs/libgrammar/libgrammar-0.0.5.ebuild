# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Google grammar check library for Chrome OS"
HOMEPAGE="https://www.chromium.org/chromium-os"

LICENSE="BSD-Google"
SLOT="0"

SRC_URI="gs://chromeos-localmirror/distfiles/libgrammar-${PV}.tar.gz"
KEYWORDS="*"

IUSE="ondevice_grammar"

S="${WORKDIR}"

src_install() {
	# Always install the header and proto files.
	insinto /usr/include/chromeos/libgrammar/
	doins grammar_interface.h
	insinto /usr/include/chromeos/libgrammar/proto/
	doins grammar_interface.proto

	if use ondevice_grammar; then
		insinto /opt/google/chrome/ml_models/grammar/
		# Install the shared library.
		insopts -m0755
		newins "libgrammar-${ARCH}.so" "libgrammar.so"
		insopts -m0644
		# Install the model files.
		doins translation_model.pb model.pb
		doins decoder_init_0.tflite decoder_step_0.tflite encoder_0.tflite
		doins wpm_model.model wpm_model.vocab
	fi
}
