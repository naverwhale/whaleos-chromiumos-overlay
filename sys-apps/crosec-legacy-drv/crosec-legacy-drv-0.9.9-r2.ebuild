# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/flashrom/flashrom-0.9.4.ebuild,v 1.5 2011/09/20 16:03:21 nativemad Exp $

#########
# WARNING!
# This is for use only for legacy users of the ChromeOS flashrom
# cros_ec driver. Use ectool or libec, shelf life is limited
# NO patches accepted!
##########

EAPI=7

# We disable automatic uprevs, since this packages should remain pinned
# on an old version of flashrom that still supports cros-ec updates.
CROS_WORKON_COMMIT="0f5d325775cba3ec2fbceaa34e13287218a658b8"
CROS_WORKON_TREE="2fa389505bdc46583f1e8697c0dfd270a1da2bfb"
CROS_WORKON_PROJECT="chromiumos/third_party/flashrom"
CROS_WORKON_LOCALNAME="flashrom"
CROS_WORKON_EGIT_BRANCH="master"

# cros_mark_as_stable --force --overlay-type public --packages \
# sys-apps/crosec-legacy-drv commit
CROS_WORKON_MANUAL_UPREV="1"

inherit cros-workon toolchain-funcs meson cros-sanitizers

DESCRIPTION="A legacy backend drv for the bio-updater stack."
HOMEPAGE="https://flashrom.org/"
SRC_URI=""

LICENSE="GPL-2"
KEYWORDS="*"
IUSE=""

src_configure() {
	local emesonargs=(
		--prefix=/opt
		-Ddefault_programmer_name=cros_ec
		-Dprogrammer="dummy"
		-Ddocumentation=disabled
		-Dman-pages=disabled
		-Dtests=disabled
		-Dich_descriptors_tool=disabled
	)
	sanitizers-setup-env
	meson_src_configure
}

src_install() {
	# The following is adapted from meson.eclass's meson_install function.
	local mesoninstallargs=(
		-C "${BUILD_DIR}"
		# Change destdir from "${D}" to ${T} to be able to select and rename
		# only the sbin/flashrom binary.
		--destdir "${T}"
		--no-rebuild
		"$@"
	)

	set -- meson install "${mesoninstallargs[@]}"
	echo "$@" >&2
	"$@" || die "install failed"

	# Only install a renamed version of the flashrom binary.
	into "/opt"
	newsbin "${T}/opt/sbin/flashrom" "crosec-legacy-drv"
}
