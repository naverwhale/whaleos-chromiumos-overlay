# Copyright (c) 2010 The Chromium OS Authors.  All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI=7
CROS_WORKON_COMMIT="dd6ae9f3a223c0a8a89a2e4c10600f7700354a53"
CROS_WORKON_TREE="e7960196b42c70e44a8d27ed2a2507dfa7b01b9e"
CROS_WORKON_PROJECT="chromiumos/platform/tpm_lite"
CROS_WORKON_LOCALNAME="tpm_lite"

inherit cros-workon toolchain-funcs

DESCRIPTION="TPM Light Command Library testsuite"
LICENSE="BSD-Google"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/tpm_lite/"
SLOT="0"
KEYWORDS="*"

DEPEND="app-crypt/trousers"

src_configure() {
	tc-export CC CXX LD AR RANLIB NM
}

src_compile() {
	emake -C src cross USE_TPM_EMULATOR=0
}

src_install() {
	pushd src
	dobin testsuite/tpmtest_*
	dolib.a tlcl/libtlcl.a
	popd
}
