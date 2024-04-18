# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "891cacbe24dacb2b2baaecb7a2d5793ccc9f9a35" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk biod .gn"

PLATFORM_SUBDIR="biod/mock-biod-test-deps"

inherit cros-workon platform

DESCRIPTION="biod test-only dbus policies. This package resides in test image only."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/biod/"

LICENSE="BSD-Google"
KEYWORDS="*"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

src_compile() {
	# We only install policy files here, no need to compile.
	:
}

src_install() {
	platform_src_install
}
