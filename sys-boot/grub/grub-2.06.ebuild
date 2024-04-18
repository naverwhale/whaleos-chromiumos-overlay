# Copyright 2010 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit autotools bash-completion-r1 eutils flag-o-matic toolchain-funcs multiprocessing

DESCRIPTION="GNU GRUB boot loader"
HOMEPAGE="https://www.gnu.org/software/grub/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

PLATFORMS=( "efi" )

PATCHES=(
	"${FILESDIR}/0001-Forward-port-ChromeOS-specific-GRUB-environment-vari.patch"
	"${FILESDIR}/0002-Forward-port-gptpriority-command-to-GRUB-2.00.patch"
	"${FILESDIR}/0003-Add-configure-option-to-reduce-visual-clutter-at-boo.patch"
	"${FILESDIR}/0004-configure-Remove-obsoleted-malign-jumps-loops-functions.patch"
	"${FILESDIR}/0005-configure-Check-for-falign-jumps-1-beside-falign-loops-1.patch"
	"${FILESDIR}/0006-configure-replace-wl-r-d-fno-common.patch"

	# Apply these upstream cosmetic patches so that the security patches
	# below apply without conflicts.
	"${FILESDIR}/0007-net-Remove-trailing-whitespaces.patch"
	"${FILESDIR}/0008-video-Remove-trailing-whitespaces.patch"

	# Security patches for the 2022/06/07 vulnerabilities:
	# https://lists.gnu.org/archive/html/grub-devel/2022-06/msg00035.html
	#
	# Generated from the grub repo with:
	# git format-patch --start-number 9 1469983eb~..2f4430cc0
	"${FILESDIR}/0009-loader-efi-chainloader-Simplify-the-loader-state.patch"
	"${FILESDIR}/0010-commands-boot-Add-API-to-pass-context-to-loader.patch"
	"${FILESDIR}/0011-loader-efi-chainloader-Use-grub_loader_set_ex.patch"
	"${FILESDIR}/0012-kern-efi-sb-Reject-non-kernel-files-in-the-shim_lock.patch"
	"${FILESDIR}/0013-kern-file-Do-not-leak-device_name-on-error-in-grub_f.patch"
	"${FILESDIR}/0014-video-readers-png-Abort-sooner-if-a-read-operation-f.patch"
	"${FILESDIR}/0015-video-readers-png-Refuse-to-handle-multiple-image-he.patch"
	"${FILESDIR}/0016-video-readers-png-Drop-greyscale-support-to-fix-heap.patch"
	"${FILESDIR}/0017-video-readers-png-Avoid-heap-OOB-R-W-inserting-huff-.patch"
	"${FILESDIR}/0018-video-readers-png-Sanity-check-some-huffman-codes.patch"
	"${FILESDIR}/0019-video-readers-jpeg-Abort-sooner-if-a-read-operation-.patch"
	"${FILESDIR}/0020-video-readers-jpeg-Do-not-reallocate-a-given-huff-ta.patch"
	"${FILESDIR}/0021-video-readers-jpeg-Refuse-to-handle-multiple-start-o.patch"
	"${FILESDIR}/0022-video-readers-jpeg-Block-int-underflow-wild-pointer-.patch"
	"${FILESDIR}/0023-normal-charset-Fix-array-out-of-bounds-formatting-un.patch"
	"${FILESDIR}/0024-net-ip-Do-IP-fragment-maths-safely.patch"
	"${FILESDIR}/0025-net-netbuff-Block-overly-large-netbuff-allocs.patch"
	"${FILESDIR}/0026-net-dns-Fix-double-free-addresses-on-corrupt-DNS-res.patch"
	"${FILESDIR}/0027-net-dns-Don-t-read-past-the-end-of-the-string-we-re-.patch"
	"${FILESDIR}/0028-net-tftp-Prevent-a-UAF-and-double-free-from-a-failed.patch"
	"${FILESDIR}/0029-net-tftp-Avoid-a-trivial-UAF.patch"
	"${FILESDIR}/0030-net-http-Do-not-tear-down-socket-if-it-s-already-bee.patch"
	"${FILESDIR}/0031-net-http-Fix-OOB-write-for-split-http-headers.patch"
	"${FILESDIR}/0032-net-http-Error-out-on-headers-with-LF-without-CR.patch"
	"${FILESDIR}/0033-fs-f2fs-Do-not-read-past-the-end-of-nat-journal-entr.patch"
	"${FILESDIR}/0034-fs-f2fs-Do-not-read-past-the-end-of-nat-bitmap.patch"
	"${FILESDIR}/0035-fs-f2fs-Do-not-copy-file-names-that-are-too-long.patch"
	"${FILESDIR}/0036-fs-btrfs-Fix-several-fuzz-issues-with-invalid-dir-it.patch"
	"${FILESDIR}/0037-fs-btrfs-Fix-more-ASAN-and-SEGV-issues-found-with-fu.patch"
	"${FILESDIR}/0038-fs-btrfs-Fix-more-fuzz-issues-related-to-chunks.patch"

	# Security patches for the 2022/11/15 vulnerabilities:
	# https://lists.gnu.org/archive/html/grub-devel/2022-11/msg00059.html
	#
	# Generated from the grub repo with:
	# git format-patch --start-number=39 f6b623607~..151467888
	"${FILESDIR}/0039-font-Reject-glyphs-exceeds-font-max_glyph_width-or-f.patch"
	"${FILESDIR}/0040-font-Fix-size-overflow-in-grub_font_get_glyph_intern.patch"
	"${FILESDIR}/0041-font-Fix-several-integer-overflows-in-grub_font_cons.patch"
	"${FILESDIR}/0042-font-Remove-grub_font_dup_glyph.patch"
	"${FILESDIR}/0043-font-Fix-integer-overflow-in-ensure_comb_space.patch"
	"${FILESDIR}/0044-font-Fix-integer-overflow-in-BMP-index.patch"
	"${FILESDIR}/0045-font-Fix-integer-underflow-in-binary-search-of-char-.patch"
	"${FILESDIR}/0046-kern-efi-sb-Enforce-verification-of-font-files.patch"
	"${FILESDIR}/0047-fbutil-Fix-integer-overflow.patch"
	"${FILESDIR}/0048-font-Fix-an-integer-underflow-in-blit_comb.patch"
	"${FILESDIR}/0049-font-Harden-grub_font_blit_glyph-and-grub_font_blit_.patch"
	"${FILESDIR}/0050-font-Assign-null_font-to-glyphs-in-ascii_font_glyph.patch"
	"${FILESDIR}/0051-normal-charset-Fix-an-integer-overflow-in-grub_unico.patch"

	# Security patch for image loaders.
	#
	# Generated from the grub repo with:
	# git format-patch --start-number=52 a85714545~..a85714545
	"${FILESDIR}/0052-video-readers-Add-artificial-limit-to-image-dimensio.patch"

	# Security patches for the 2023/10/03 NTFS vulnerabilities:
	# https://lists.gnu.org/archive/html/grub-devel/2023-10/msg00028.html
	#
	# Generated from the grub repo with:
	# git format-patch --start-number=53 43651027d~..e58b870ff
	"${FILESDIR}/0053-fs-ntfs-Fix-an-OOB-write-when-parsing-the-ATTRIBUTE_.patch"
	"${FILESDIR}/0054-fs-ntfs-Fix-an-OOB-read-when-reading-data-from-the-r.patch"
	"${FILESDIR}/0055-fs-ntfs-Fix-an-OOB-read-when-parsing-directory-entri.patch"
	"${FILESDIR}/0056-fs-ntfs-Fix-an-OOB-read-when-parsing-bitmaps-for-ind.patch"
	"${FILESDIR}/0057-fs-ntfs-Fix-an-OOB-read-when-parsing-a-volume-label.patch"
	"${FILESDIR}/0058-fs-ntfs-Make-code-more-readable.patch"

	# Patch for WhaleOS to enter network recovery mode
	"${FILESDIR}/1001-Add-hidden-hotkey-to-enter-menu.patch"
	"${FILESDIR}/1002-Apply-whaleos-menu-entry-and-delete-cli-edit.patch"
)

BDEPEND="
	>=sys-devel/flex-2.5.35
	sys-devel/bison
	sys-apps/help2man
	app-arch/xz-utils
"

grub_targets() {
	case ${ARCH} in
	x86|amd64) echo "i386 x86_64";;
	arm64) echo "arm64";;
	*) die "Unsupported ARCH ${ARCH}";;
	esac
}

src_prepare() {
	default

	bash autogen.sh || die
	# Fix timestamps to prevent unnecessary rebuilding
	find "${S}" -exec touch -r "${S}/configure" {} +
}

src_configure() {
	# GRUB doesn't compile with clang on arm64 (b/290883718). Use gcc instead.
	use arm64 && cros_use_gcc

	tc-export TARGET_CC NM OBJCOPY STRIP
	export TARGET_NM="${NM}"
	export TARGET_OBJCOPY="${OBJCOPY}"
	export TARGET_STRIP="${STRIP}"

	# --gc-sections must be used with other flags including --entry, --undefined
	# and --gc-keep-exported to specify which symbols should be kept. GRUB
	# modules contain an additional section module_license which contains only a
	# string without any symbols. The flags mentioned before can only exclude
	# symbols, not sections from gc. Therefore to prevent module_license from
	# being stripped by gc, we need to filter it from ldflags.
	filter-ldflags "-Wl,--gc-sections"

  # Fix build errors for Whale OS
	filter-ldflags "-Wl,--icf=all"

	local platform target
	multijob_init
	for platform in "${PLATFORMS[@]}" ; do
		for target in $(grub_targets) ; do
			mkdir -p "${target}-${platform}-build"
			pushd "${target}-${platform}-build" >/dev/null || die

			# Set the --target to the current --host by default.  This is what
			# autoconf will basically do.  However, if we're building a target
			# that doesn't match the current host (e.g. building a 32-bit EFI
			# for a x86_64 board), override it so grub will build the right file.
			local ctarget="${CHOST}"
			case ${CHOST}:${target} in
			i?86-*:x86_64|x86_64-*:i386) ctarget="${target}";;
			esac

			# GRUB defaults to a --program-prefix set based on target
			# platform; explicitly set it to nothing to install unprefixed
			# tools.  https://savannah.gnu.org/bugs/?39818
			ECONF_SOURCE="${S}" multijob_child_init econf \
				--disable-werror \
				--disable-grub-mkfont \
				--disable-grub-mount \
				--disable-device-mapper \
				--disable-efiemu \
				--disable-libzfs \
				--disable-nls \
				--enable-quiet-boot \
				--sbindir=/sbin \
				--bindir=/bin \
				--libdir="/$(get_libdir)" \
				--with-platform="${platform}" \
				--target="${ctarget}" \
				--program-prefix=
			popd >/dev/null || die
		done
	done
	multijob_finish
}

src_compile() {
	local platform target
	multijob_init
	for platform in "${PLATFORMS[@]}" ; do
		for target in $(grub_targets) ; do
			multijob_child_init \
				emake -C "${target}-${platform}-build" -j1
		done
	done
	multijob_finish
}

src_install() {
	local platform target
	# The installations have several file conflicts that prevent
	# parallel installation.
	for platform in "${PLATFORMS[@]}" ; do
		for target in $(grub_targets) ; do
			emake -C "${target}-${platform}-build" DESTDIR="${D}" \
				install bashcompletiondir="$(get_bashcompdir)"

			# Disable stripping for several file types,
			# otherwise the image produced by grub-mkimage
			# does not boot.
			local -a modules=( "${D}/$(get_libdir)/grub/${target}-${platform}"/*.{img,mod,module} )
			dostrip -x "${modules[@]#"${D}"}"
		done
	done
}
