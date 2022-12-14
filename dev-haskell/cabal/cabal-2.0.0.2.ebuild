# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# ebuild generated by hackport 0.5.3.9999
#hackport: flags: -parsec-struct-diff

CABAL_FEATURES="lib profile test-suite"
CABAL_FEATURES+=" nocabaldep" # in case installed Cabal is broken
inherit haskell-cabal

MY_PN="Cabal"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A framework for packaging Haskell software"
HOMEPAGE="http://www.haskell.org/cabal/"
SRC_URI="https://hackage.haskell.org/package/${MY_P}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
#not keyworded yet: many packages are broken
KEYWORDS="*"
IUSE=""

RESTRICT=test # circular dependencies

RDEPEND=">=dev-lang/ghc-7.8.1:="
DEPEND="${RDEPEND}"

CABAL_CORE_LIB_GHC_PV="PM:8.2.1"

PATCHES=("${FILESDIR}"/${P}-no-bootstrap.patch)

S="${WORKDIR}/${MY_P}"

src_configure() {
	haskell-cabal_src_configure \
		--flag=-parsec-struct-diff
}
