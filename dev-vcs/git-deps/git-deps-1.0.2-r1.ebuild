# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGIT_REPO_URI="https://github.com/aspiers/git-deps"
EGIT_BRANCH=master

PYTHON_COMPAT=( python3_{6..8} )

inherit eutils python-single-r1

DESCRIPTION="git commit dependency analysis tool"
HOMEPAGE="https://github.com/aspiers/git-deps"
SRC_URI="https://github.com/aspiers/git-deps/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="*"
SLOT="0/${PVR}"

RDEPEND="
	$(python_gen_cond_dep '
		dev-python/flask[${PYTHON_MULTI_USEDEP}]
		dev-python/pygit2[${PYTHON_MULTI_USEDEP}]
	')
	net-libs/nodejs
	${PYTHON_DEPS}
	"
DEPEND="${RDEPEND}"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_install() {
	python_domodule git_deps
	python_newscript "${FILESDIR}/git-deps" git-deps
}

pkg_postinst() {
	elog "Notes regarding the '--serve' option:"
	elog "Please run 'npm install browserify' once"
	elog "Copy the html sources:"
	elog "rsync -av ${EROOT}/usr/share/${PN}/html ~/git-deps-html"
	elog "cd ~/git-deps-html"
	elog "npm install"
	elog "browserify -t coffeeify -d js/git-deps-graph.coffee -o js/bundle.js"
}
