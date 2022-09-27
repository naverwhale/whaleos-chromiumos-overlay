# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="TFLite models and supporting assets used for testing ML & NNAPI."
HOMEPAGE="https://chromium.googlesource.com/aosp/platform/test/mlts/models/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="label_image benchmark_model"

# Basic test model (mobilenet.tflite, grace_hopper.bmp, labels.txt)
LABEL_IMAGE_TARBALL="ml-test-assets-label-image-assets_20200721.tar.xz"

# Models from https://android.googlesource.com/platform/test/mlts/models
# tarball is from commit 73313692ee90e6d768cd086fbb7c94298ecaf1ac 2020-07-03
AOSP_MLTS_MODELS_TARBALL="aosp-mlts-models-7331369.tar.xz"

SRC_URI="
	label_image? ( gs://chromeos-localmirror/distfiles/${LABEL_IMAGE_TARBALL} )
	benchmark_model? ( gs://chromeos-localmirror/distfiles/${AOSP_MLTS_MODELS_TARBALL} )
"

S="${WORKDIR}"

src_install() {
	if use label_image || use benchmark_model; then
		insinto /usr/local/share/ml-test-assets
		doins -r ./*
	fi
}
