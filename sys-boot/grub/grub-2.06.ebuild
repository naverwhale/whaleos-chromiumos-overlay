# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit bash-completion-r1 eutils toolchain-funcs multiprocessing

DESCRIPTION="GNU GRUB 2 boot loader"
HOMEPAGE="http://www.gnu.org/software/grub/"
SRC_URI="ftp://ftp.gnu.org/gnu/grub/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="-* amd64"

PROVIDE="virtual/bootloader"

export STRIP_MASK="*.img *.mod *.module"

# The ordering doesn't seem to matter.
PLATFORMS=( "efi" "pc" )
TARGETS=( "i386" "x86_64" )

src_prepare() {
	epatch "${FILESDIR}/0001-Forward-port-ChromeOS-specific-GRUB-environment-vari.patch"
	epatch "${FILESDIR}/0002-Forward-port-gptpriority-command-to-GRUB-2.00.patch"
	epatch "${FILESDIR}/b189992601-no-soft-float.patch"
	epatch "${FILESDIR}/0004-Add-hidden-hotkey-to-recover.patch"

	bash autogen.sh || die
}

src_configure() {
	filter-ldflags "-Wl,--gc-sections"
	filter-ldflags "-Wl,--icf=all"
	local platform target
	# Fix timestamps to prevent unnecessary rebuilding
	find "${S}" -exec touch -r "${S}/configure" {} +
	multijob_init
	for platform in "${PLATFORMS[@]}" ; do
		for target in "${TARGETS[@]}" ; do
			mkdir -p ${target}-${platform}-build
			pushd ${target}-${platform}-build >/dev/null
			# GRUB defaults to a --program-prefix set based on target
			# platform; explicitly set it to nothing to install unprefixed
			# tools.  https://savannah.gnu.org/bugs/?39818
			ECONF_SOURCE="${S}" multijob_child_init econf \
				TARGET_CC="$(tc-getCC)" \
				--disable-werror \
				--disable-grub-mkfont \
				--disable-grub-mount \
				--disable-device-mapper \
				--disable-efiemu \
				--disable-libzfs \
				--disable-nls \
				--sbindir=/sbin \
				--bindir=/bin \
				--libdir=/$(get_libdir) \
				--with-platform=${platform} \
				--target=${target} \
				--program-prefix=
			popd >/dev/null
		done
	done
	multijob_finish
}

src_compile() {
	local platform target
	multijob_init
	for platform in "${PLATFORMS[@]}" ; do
		for target in "${TARGETS[@]}" ; do
			multijob_child_init \
				emake -C ${target}-${platform}-build -j1
		done
	done
	multijob_finish
}

src_install() {
	local platform target
	# The installations have several file conflicts that prevent
	# parallel installation.
	for platform in "${PLATFORMS[@]}" ; do
		for target in "${TARGETS[@]}" ; do
			emake -C ${target}-${platform}-build DESTDIR="${D}" \
				install bashcompletiondir="$(get_bashcompdir)"
		done
	done
}
