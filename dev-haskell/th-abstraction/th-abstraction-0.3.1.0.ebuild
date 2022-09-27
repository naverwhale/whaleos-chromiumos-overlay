# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=6

#hackport: flags: sse41:cpu_flags_x86_sse4_1,sse2:cpu_flags_x86_sse2,integer-gmp:gmp

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="Nicer interface for reified information about data types"
HOMEPAGE="http://hackage.haskell.org/package/th-abstraction"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="ISC"
SLOT="0/${PV}"
KEYWORDS="*"
IUSE="+cpu_flags_x86_sse2 cpu_flags_x86_sse4_1 test"

RDEPEND=">=dev-lang/ghc-8.4.3:="

DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.8
"

src_configure() {
	haskell-cabal_src_configure \
		$(cabal_flag cpu_flags_x86_sse2 sse2) \
		$(cabal_flag cpu_flags_x86_sse4_1 sse41)
}
