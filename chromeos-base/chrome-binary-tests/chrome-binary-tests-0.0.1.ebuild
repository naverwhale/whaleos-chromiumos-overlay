# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Install Chromium binary tests to test image"
HOMEPAGE="http://www.chromium.org"
SRC_URI=""

LICENSE="BSD-Google"

SLOT="0"
KEYWORDS="*"
IUSE="vaapi v4l2_codec"
S="${WORKDIR}"

DEPEND="chromeos-base/chromeos-chrome"

src_install() {
	exeinto /usr/libexec/chrome-binary-tests
	# The binary tests in ${BINARY_DIR} are built by chrome-chrome.
	# If you add/remove a binary here, please:
	# - Also do so for CHROME_TEST_BINARIES in
	#   src/platform/bisect-kit/bisect_kit/cr_util.py
	# - Also do so for Chromium's chromiumos_preflight target:
	#   https://source.chromium.org/chromium/chromium/src/+/master:BUILD.gn;drc=b3b52847c7efe6fd6e2e771f3098a1e8b8a5060f;l=913
	#   This will help ensure any build breakages in the following targets
	#   are caught by Chrome's CQ first.
	BINARY_DIR="${SYSROOT}/usr/local/build/autotest/client/deps/chrome_test/test_src/out/Release"
	doexe "${BINARY_DIR}/capture_unittests"
	doexe "${BINARY_DIR}/dawn_end2end_tests"
	doexe "${BINARY_DIR}/dawn_unittests"
	doexe "${BINARY_DIR}/jpeg_decode_accelerator_unittest"
	doexe "${BINARY_DIR}/ozone_gl_unittests"
	doexe "${BINARY_DIR}/sandbox_linux_unittests"
	doexe "${BINARY_DIR}/wayland_client_perftests"

	if use vaapi || use v4l2_codec; then
		doexe "${BINARY_DIR}/image_processor_test"
		doexe "${BINARY_DIR}/jpeg_encode_accelerator_unittest"
		doexe "${BINARY_DIR}/video_decode_accelerator_perf_tests"
		doexe "${BINARY_DIR}/video_decode_accelerator_tests"
		doexe "${BINARY_DIR}/video_encode_accelerator_perf_tests"
		doexe "${BINARY_DIR}/video_encode_accelerator_tests"
	fi

	if use vaapi; then
		doexe "${BINARY_DIR}/decode_test"
		doexe "${BINARY_DIR}/vaapi_unittest"
	fi
}
