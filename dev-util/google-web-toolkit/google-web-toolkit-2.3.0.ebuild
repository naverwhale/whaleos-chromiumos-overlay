# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit eutils java-utils-2

MY_P=gwt-${PV}

DESCRIPTION="Development toolkit for building and optimizing complex browser-based applications"
HOMEPAGE="http://code.google.com/webtoolkit/"
SRC_URI="http://${PN}.googlecode.com/files/${MY_P}.zip"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples"

RDEPEND=">=virtual/jre-1.5"

S=${WORKDIR}/${MY_P}

src_install() {
	local f
	local exes=(
		benchmarkViewer
		i18nCreator
		webAppCreator
	)
	insinto /opt/${PN}
	doins *.jar *.dtd *.war

	exeinto /opt/${PN}
	doexe "${exes[@]}"
	for f in "${exes[@]}" ; do
		make_wrapper $f /opt/${PN}/$f "" "" /opt/bin || die "make_wrapper $f failed"
	done

	dodoc about.{txt,html} release_notes.html

	if use doc; then
		java-pkg_dojavadoc doc/javadoc
	fi

	# TODO: Compile examples, rather than using the distributed class files
	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r samples
	fi
}
