# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT=("a7d83f416a8915930ffebb61280f935300244c5c" "dd52f5f53116b5880387bc1a878478e172b768be")
CROS_WORKON_TREE=("791c6808b4f4f5f1c484108d66ff958d65f8f1e3" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb" "d5b2e1140bb5d80e845bd170bd364e892b05ebd1")
inherit cros-constants

CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME=("../platform2" "../aosp/external/puffin")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/external/puffin")
CROS_WORKON_EGIT_BRANCH=("main" "master")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/puffin")
CROS_WORKON_REPO=("${CROS_GIT_HOST_URL}" "${CROS_GIT_AOSP_URL}")
CROS_WORKON_SUBTREE=("common-mk .gn" "")
CROS_WORKON_MANUAL_UPREV=1

PLATFORM_SUBDIR="puffin"

inherit cros-workon platform

DESCRIPTION="Puffin: Deterministic patching tool for deflate streams"
HOMEPAGE="https://android.googlesource.com/platform/external/puffin/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="asan fuzzer"

COMMON_DEPEND="chromeos-base/libbrillo:=[asan?,fuzzer?]
	dev-libs/protobuf:=
	dev-util/bsdiff:=
"

RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

src_install() {
	if use cros_host; then
		dobin "${OUT}"/puffin
	fi
	dolib.a "${OUT}"/libpuffpatch.a
	dolib.a "${OUT}"/libpuffdiff.a

	insinto /usr/include
	doins -r src/include/puffin

	insinto "/usr/$(get_libdir)/pkgconfig"
	doins libpuffdiff.pc libpuffpatch.pc

	for f in "huff" "puff" "puffpatch"; do
		local fuzzer_component_id="31714"
		platform_fuzzer_install "${S}"/OWNERS "${OUT}/puffin_${f}_fuzzer" \
			--comp "${fuzzer_component_id}"
	done
}

platform_pkg_test() {
	platform_test "run" "${OUT}/puffin_test"

	# Run fuzzers.
	for f in "huff" "puff" "puffpatch"; do
		platform_fuzzer_test "${OUT}/puffin_${f}_fuzzer"
	done
}
