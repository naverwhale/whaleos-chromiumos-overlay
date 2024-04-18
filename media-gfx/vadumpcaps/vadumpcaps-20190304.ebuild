# Copyright 2019 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit toolchain-funcs flag-o-matic

DESCRIPTION="Dump capabilities of VA-API device/driver"
HOMEPAGE="https://github.com/fhvwy/vadumpcaps"

GIT_SHA1="fb4dfef76c0fa08f853af377d5d4945d5fb3001c"
SRC_URI="https://github.com/fhvwy/vadumpcaps/archive/${GIT_SHA1}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	>=x11-libs/libva-2.1.0
	>=x11-libs/libdrm-2.4"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/avoid_using_VAProcFilterHighDynamicRangeToneMapping.patch
	"${FILESDIR}"/do_not_use_shell_pkg-config.patch
)

src_configure() {
	append-ldflags "$($(tc-getPKG_CONFIG) --libs libva-drm libva)"
}

src_compile() {
	emake vadumpcaps
}

src_install() {
	dobin vadumpcaps
}
