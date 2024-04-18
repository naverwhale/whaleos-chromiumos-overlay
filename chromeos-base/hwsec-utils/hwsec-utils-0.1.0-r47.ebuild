# Copyright 2022 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="7405baf979339d70d1629ae231167d697e8177a7"
CROS_WORKON_TREE="1132221e2968d1e549f53ddfe138f0903187645d"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_SUBTREE="hwsec-utils"

inherit cros-workon cros-rust

DESCRIPTION="Hwsec-related features."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/hwsec-utils/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="cr50_onboard test ti50_onboard"
REQUIRED_USE="^^ ( ti50_onboard cr50_onboard )"
CANDIDATES=( "cr50_onboard" "ti50_onboard" )

DEPEND="
	dev-rust/third-party-crates-src:=
	dev-rust/libchromeos:=
	sys-apps/dbus:=
"
# (crbug.com/1182669): build-time only deps need to be in RDEPEND so they are pulled in when
# installing binpkgs since the full source tree is required to use the crate.
RDEPEND="${DEPEND}"

src_compile() {
	local features=()

	local candidate
	for candidate in "${CANDIDATES[@]}"; do
		if use "${candidate}"; then
			features+=("${candidate}")
		fi
	done

	cros-rust_src_compile --features="${features[*]}"
}

src_install() {
	cros-rust_src_install

	exeinto /usr/share/cros/hwsec-utils
	files=(
		cr50_disable_sleep
		gsc_flash_log
		gsc_get_name
		gsc_read_rma_sn_bits
		gsc_reset
		gsc_set_board_id
		gsc_set_factory_config
		gsc_set_sn_bits
		gsc_update
		gsc_verify_ro
		tpm2_read_board_id
	)
	for f in "${files[@]}"; do
		doexe "$(cros-rust_get_build_dir)/${f}"
	done
}

src_test() {
	local candidate
	for candidate in "${CANDIDATES[@]}"; do
		cros-rust_src_test --features="${candidate}"
	done
}
