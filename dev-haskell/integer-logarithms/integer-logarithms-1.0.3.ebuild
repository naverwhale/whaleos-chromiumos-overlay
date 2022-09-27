# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=6

#hackport: flags: sse41:cpu_flags_x86_sse4_1,sse2:cpu_flags_x86_sse2,integer-gmp:gmp

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="Integer logarithms"
HOMEPAGE="http://hackage.haskell.org/package/integer-logarithms"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0/${PV}"
KEYWORDS="*"
IUSE="+cpu_flags_x86_sse2 cpu_flags_x86_sse4_1 test"

RDEPEND=">=dev-lang/ghc-8.0.2:="

DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.8
	>=dev-haskell/nats-1.1.2 <dev-haskell/nats-1.2
	test? ( dev-haskell/hunit
		>=dev-haskell/quickcheck-2.4.0.1
		>=dev-haskell/random-1.0 <dev-haskell/random-1.2
		>=dev-haskell/test-framework-0.3.3
		dev-haskell/test-framework-hunit
		>=dev-haskell/test-framework-quickcheck2-0.2.9 )
"

src_configure() {
	haskell-cabal_src_configure \
		$(cabal_flag cpu_flags_x86_sse2 sse2) \
		$(cabal_flag cpu_flags_x86_sse4_1 sse41)
}
