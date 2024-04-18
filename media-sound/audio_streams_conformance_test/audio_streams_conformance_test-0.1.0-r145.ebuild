# Copyright 2022 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI="7"

CROS_WORKON_COMMIT="0a9d1cb8be29e49c355ea8b18cd58506dbbaf6e5"
CROS_WORKON_TREE="f2ccaca3a6023f088ebb72e8f1ff42b461c170fd"
CROS_WORKON_LOCALNAME="../platform/crosvm"
CROS_WORKON_PROJECT="chromiumos/platform/crosvm"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_RUST_SUBDIR="./"

inherit cros-workon cros-rust

DESCRIPTION="A Tool to verify the implementation correctness of audio_streams API."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/crosvm/+/refs/heads/main/audio_streams_conformance_test"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="test"

DEPEND="
	media-sound/cras-client:=
	dev-libs/wayland:=
	dev-rust/libchromeos:=
	dev-rust/third-party-crates-src:=
	dev-rust/minijail:=
	dev-rust/system_api:=
"

src_compile() {
	local features=(
		chromeos
	)

	ecargo_build -v \
		-p audio_streams_conformance_test \
		--features="${features[*]}" ||
		die "cargo build failed"
}


src_install() {
	dobin "$(cros-rust_get_build_dir)/audio_streams_conformance_test"
}
