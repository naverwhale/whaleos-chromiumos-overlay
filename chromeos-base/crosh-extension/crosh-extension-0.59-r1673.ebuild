# Copyright 2016 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="8d67cc6430647aff440f312a9643259355c8a863"
CROS_WORKON_TREE=("7180f851923c8f58c79f515298117fddca1b6874" "9bcf16d9cb12645a881a0c673c1fd46c2beb093f" "264ec4c14fb31f84fcc5983503be578d2a8fb2c4" "58ee5ae773005b84670334ae5530f1affcb2dc21" "6c6bcb74a67f06b9b41f04f7977bd94998549216" "4a8a3d2135b93784093c7f4c5d2a54b921930145" "ddc198a1f3d5ce296d267f981ca0b0bb3b340d5c")
CROS_WORKON_PROJECT="apps/libapps"
CROS_WORKON_LOCALNAME="third_party/libapps"
CROS_WORKON_SUBTREE="libdot hterm nassh ssh_client terminal wasi-js-bindings wassh"

inherit cros-workon

DESCRIPTION="The Chromium OS Shell extension (the HTML/JS rendering part)"
HOMEPAGE="https://chromium.googlesource.com/apps/libapps/+/HEAD/nassh/docs/chromeos-crosh.md"
# These are kept in sync with libdot.py settings.
FONTS_HASHES=(
	# Current one.
	d6dc5eaf459abd058cd3aef1e25963fde893f9d87f5f55f340431697ce4b3506
	# Next one.
)
NODE_HASHES=(
	# Current one.
	16.13.0/ab9544e24e752d3d17f335fb7b2055062e582d11
	# Next one.
)
NPM_HASHES=(
	# Current one.
	473756c69f6978a0b9ebb636e20c6afc0a05614e9bf728dec3b6303d74799690
	# Next one.
	9fa46a29844cc1c69c67698c8dddff1e5bcd015037ffe30e6fad786b9e674719
)
PLUGIN_VERSIONS=(
	# Current one.
	0.54
	# Next one.
	0.58
)
SRC_URI="
	$(printf 'https://storage.googleapis.com/chromium-nodejs/%s ' "${NODE_HASHES[@]}")
	$(printf 'https://storage.googleapis.com/chromeos-localmirror/secureshell/distfiles/fonts-%s.tar.xz ' \
		"${FONTS_HASHES[@]}")
	$(printf 'https://storage.googleapis.com/chromeos-localmirror/secureshell/distfiles/node_modules-%s.tar.xz ' \
		"${NPM_HASHES[@]}")
	$(printf 'https://storage.googleapis.com/chromeos-localmirror/secureshell/releases/%s.tar.xz ' \
		"${PLUGIN_VERSIONS[@]}")
"

# The archives above live on Google maintained sites.
RESTRICT="mirror"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="*"
IUSE=""

RDEPEND="!<chromeos-base/common-assets-0.0.2"

BDEPEND="
	app-arch/unzip
	app-arch/zip
	sys-devel/gcc
"

e() {
	echo "$@"
	"$@" || die
}

src_prepare() {
	default
	# TODO(vapier): Rework this integration.
	sed -i \
		-e '1iconst gitDate = pkg.gitDate;' \
		-e '1iconst version = pkg.version;' \
		libdot/js/deps_resources.shim.js || die
	sed -i \
		-e '/^import .*package.json/d' \
		-e "s|pkg.version|'${PV}'|" \
		-e "s|pkg.gitDate|'$(date)'|" \
		-e "s|pkg.gitCommitHash|'${CROS_WORKON_COMMIT}'|" \
		libdot/js/deps_resources.shim.js \
		hterm/js/deps_resources.shim.js || die
}

src_compile() {
	export VCSID="${CROS_WORKON_COMMIT:-${PF}}"
	e ./nassh/bin/mkdist --crosh-only
}

src_install() {
	local dir="/usr/share/chromeos-assets/crosh_builtin"
	dodir "${dir}"
	unzip -d "${D}${dir}" nassh/dist/crosh.zip || die
	local pnacl="${D}${dir}/plugin/pnacl"
	if ! use arm && ! use arm64; then
		rm "${pnacl}/ssh_client_nl_arm.nexe"* || die
	fi
	if ! use x86 ; then
		rm "${pnacl}/ssh_client_nl_x86_32.nexe"* || die
	fi
	if ! use amd64 ; then
		rm "${pnacl}/ssh_client_nl_x86_64.nexe"* || die
	fi
}
