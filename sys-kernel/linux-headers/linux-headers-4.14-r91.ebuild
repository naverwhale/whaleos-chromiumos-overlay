# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="d2d95e8af89939f893b1443135497c1f5572aebc"
CROS_WORKON_TREE="776139a53bc86333de8672a51ed7879e75909ac9"
CROS_WORKON_PROJECT="chromiumos/infra/build/empty-project"
CROS_WORKON_LOCALNAME="../platform/empty-project"

inherit cros-workon

# cros-workon's 9999 doesn't play nicely with the other version detection in
# here.
MY_PV="4.14"

# shellcheck disable=SC2034
ETYPE="headers"
# shellcheck disable=SC2034
H_SUPPORTEDARCH="alpha amd64 arc arm arm64 avr32 bfin cris frv hexagon hppa ia64 m32r m68k metag microblaze mips mn10300 nios2 openrisc ppc ppc64 s390 score sh sparc tile x86 xtensa"
inherit kernel-2
# shellcheck disable=SC2034
CKV="${MY_PV}"
detect_version

PATCH_VER="1"
SRC_URI="mirror://gentoo/gentoo-headers-base-${MY_PV}.tar.xz
	${PATCH_VER:+mirror://gentoo/gentoo-headers-${MY_PV}-${PATCH_VER}.tar.xz}"
S="${WORKDIR}/gentoo-headers-base-${MY_PV}"

KEYWORDS="*"

BDEPEND="
	app-arch/xz-utils
	dev-lang/perl"

[[ -n ${PATCH_VER} ]] && PATCHES=( "${WORKDIR}/${MY_PV}" )

#
# NOTE: All the patches must be applicable using patch -p1.
#
PATCHES+=(
	"${FILESDIR}/0008-videodev2.h-add-IPU3-meta-buffer-format.patch"
	"${FILESDIR}/0009-uapi-intel-ipu3-Add-user-space-ABI-definitions.patch"
	"${FILESDIR}/0010-virtwl-add-virtwl-driver.patch"
	"${FILESDIR}/0012-FROMLIST-media-rkisp1-Add-user-space-ABI-definitions.patch"
	"${FILESDIR}/0014-BACKPORT-add-qrtr-header-file.patch"
	"${FILESDIR}/0024-UPSTREAM-nl80211-mac80211-mesh-add-hop-count-to-mpath.patch"
	"${FILESDIR}/0025-UPSTREAM-nl80211-mac80211-mesh-add-mesh-path-change-c.patch"
	"${FILESDIR}/0026-FROMLIST-Input_add_KEY_KBD_LAYOUT_NEXT.patch"
	"${FILESDIR}/0030-BACKPORT-sync-nl80211.h-to-v5.8.patch"
	"${FILESDIR}/0031-FROMLIST-media-pixfmt-Add-Mediatek-ISP-P1-image-meta.patch"
	"${FILESDIR}/0032-BACKPORT-add-udmabuf-header.patch"
	"${FILESDIR}/0033-FROMGIT-Input-add-privacy-screen-toggle-keycode.patch"
	"${FILESDIR}/0034-UPSTREAM-Input-add-REL_WHEEL_HI_RES-and-REL_HWHEEL_H.patch"
	"${FILESDIR}/0035-BACKPORT-Input-Add-FULL_SCREEN-ASPECT_RATIO-SELECTIV.patch"
	"${FILESDIR}/0036-CHROMIUM-Add-fscrypt-header.patch"
	"${FILESDIR}/0038-BACKPORT-Add-io_uring-IO-interface.patch"
	"${FILESDIR}/0039-BACKPORT-net-qualcomm-rmnet-Export-mux_id-and-flags-to-netlink.patch"
	"${FILESDIR}/0040-BACKPORT-y2038-add-64-bit-time_t-syscalls-to-all-32-.patch"
	"${FILESDIR}/0042-CHROMIUM-linux-headers-update-headers-with-UVC-1.5-R.patch"
	"${FILESDIR}/0043-BACKPORT-vfs-add-faccessat2-syscall.patch"
	"${FILESDIR}/0044-CHROMIUM-v4l2-controls-use-very-high-ID-for-ROI-auto.patch"
	"${FILESDIR}/0047-BACKPORT-drm-add-panfrost_drm.h.patch"
	"${FILESDIR}/0048-ASoC-SOF-Add-userspace-ABI-support.patch"
	"${FILESDIR}/0052-BACKPORT-add-rseq-syscall-definitions.patch"
	"${FILESDIR}/0053-BACKPORT-fanotify-add-support-for-create-attrib-move.patch"
	"${FILESDIR}/0054-BACKPORT-LoadPin-Enable-loading-from-trusted-dm-veri.patch"
	"${FILESDIR}/0056-BACKPORT-add-close_range-syscall-definitions.patch"
	"${FILESDIR}/0057-BACKPORT-fanotify-add-API-to-attach-detach-super-blo.patch"
	"${FILESDIR}/0058-BACKPORT-kexec-file-load.patch"
	"${FILESDIR}/0060-CHROMIUM-Add-dma-heap-header.patch"
	"${FILESDIR}/0061-BACKPORT-FROMLIST-media-uvcvideo-implement-UVC-v1.5-.patch"
	"${FILESDIR}/0062-CHROMIUM-media-uvcvideo-support-roi-coordinate-syste.patch"
	"${FILESDIR}/0070-prctl-Add-speculation-control-prctls.patch"
	"${FILESDIR}/0100-BACKPORT-add-pidfd_open-syscall-definitions.patch"
	"${FILESDIR}/0101-BACKPORT-add-clone3-syscall-definitions.patch"
	"${FILESDIR}/0102-UPSTREAM-vsock-add-VMADDR_CID_LOCAL-definition.patch"
	"${FILESDIR}/0103-BACKPORT-UPSTREAM-rtnetlink-provide-permanent-hardwa.patch"
)

# This list contains all V4L2 patches backported from upstream, along with
# two downstream patches that are V4L2-related, need to be applied after
# the V4L2 bunch, and scheduled to be removed.
PATCHES+=(
	"${FILESDIR}/v4l2/0001-UPSTREAM-media-videodev2.h-v4l2-ioctl-add-IPU3-raw10.patch"
	"${FILESDIR}/v4l2/0002-BACKPORT-media-replace-all-spaces-tab-occurrences.patch"
	"${FILESDIR}/v4l2/0003-UPSTREAM-media-videodev2.h-Add-v4l2-definition-for-HEVC.patch"
	"${FILESDIR}/v4l2/0004-BACKPORT-media-v4l2-Add-v4l2-control-IDs-for-HEVC-encoder.patch"
	"${FILESDIR}/v4l2/0005-UPSTREAM-media-v4l2-ctrl-Change-control-for-VP8-prof.patch"
	"${FILESDIR}/v4l2/0006-BACKPORT-media-v4l2-ctrl-Add-control-for-VP9-profile.patch"
	"${FILESDIR}/v4l2/0007-BACKPORT-media-uapi-linux-media.h-add-request-API.patch"
	"${FILESDIR}/v4l2/0008-BACKPORT-media-videodev2.h-add-request_fd-field-to-v.patch"
	"${FILESDIR}/v4l2/0009-BACKPORT-media-videodev2.h-Add-request_fd-field-to-v.patch"
	"${FILESDIR}/v4l2/0010-UPSTREAM-media-videodev2.h-add-new-capabilities-for-.patch"
	"${FILESDIR}/v4l2/0011-UPSTREAM-v4l2-controls-add-a-missing-include.patch"
	"${FILESDIR}/v4l2/0012-BACKPORT-media-vb2-Allow-reqbufs-0-with-in-use-MMAP-.patch"
	"${FILESDIR}/v4l2/0013-BACKPORT-media-v4l-Add-support-for-V4L2_BUF_TYPE_MET.patch"
	"${FILESDIR}/v4l2/0014-UPSTREAM-media-videodev2.h-add-v4l2_timeval_to_ns-in.patch"
	"${FILESDIR}/v4l2/0015-UPSTREAM-media-v4l-uAPI-V4L2_BUF_TYPE_META_OUTPUT-is.patch"
	# Above patches are from before and up to v5.4
	"${FILESDIR}/v4l2/0021-BACKPORT-media-vb2-add-V4L2_BUF_FLAG_M2M_HOLD_CAPTUR.patch"
	"${FILESDIR}/v4l2/0022-BACKPORT-media-videodev2.h-add-V4L2_DEC_CMD_FLUSH.patch"
	"${FILESDIR}/v4l2/0023-BACKPORT-media-videobuf2-add-V4L2_FLAG_MEMORY_NON_CO.patch"
	"${FILESDIR}/v4l2/0024-BACKPORT-media-videobuf2-handle-V4L2_FLAG_MEMORY_NON.patch"
	"${FILESDIR}/v4l2/0025-BACKPORT-media-media-v4l2-remove-V4L2_FLAG_MEMORY_NO.patch"
	"${FILESDIR}/v4l2/0026-BACKPORT-media-v4l2-ctrl-Add-VP9-codec-levels.patch"
	# Above patches are from before and up to v5.10
	"${FILESDIR}/v4l2/0031-BACKPORT-media-videodev2.h-v4l2-ioctl-add-rkisp1-met.patch"
	"${FILESDIR}/v4l2/0032-BACKPORT-media-Rename-stateful-codec-control-macros.patch"
	"${FILESDIR}/v4l2/0033-BACKPORT-media-controls-Add-the-stateless-codec-cont.patch"
	"${FILESDIR}/v4l2/0034-BACKPORT-media-uapi-Move-parsed-H264-pixel-format-ou.patch"
	"${FILESDIR}/v4l2/0035-BACKPORT-media-uapi-Move-the-H264-stateless-control-.patch"
	"${FILESDIR}/v4l2/0036-BACKPORT-media-uapi-move-H264-stateless-controls-out.patch"
	"${FILESDIR}/v4l2/0037-BACKPORT-media-uapi-Move-parsed-VP8-pixel-format-out.patch"
	"${FILESDIR}/v4l2/0038-BACKPORT-media-uapi-Move-the-VP8-stateless-control-t.patch"
	"${FILESDIR}/v4l2/0039-BACKPORT-media-uapi-move-VP8-stateless-controls-out-.patch"
	# Above patches are from before and up to v5.15
	"${FILESDIR}/v4l2/0041-UPSTREAM-media-add-Mediatek-s-MM21-format.patch"
	"${FILESDIR}/v4l2/0042-BACKPORT-media-videobuf2-add-V4L2_MEMORY_FLAG_NON_CO.patch"
	"${FILESDIR}/v4l2/0043-BACKPORT-media-videobuf2-handle-V4L2_MEMORY_FLAG_NON.patch"
	"${FILESDIR}/v4l2/0044-BACKPORT-media-uapi-Add-VP9-stateless-decoder-contro.patch"
	"${FILESDIR}/v4l2/0045-BACKPORT-media-Add-P010-video-format.patch"
	"${FILESDIR}/v4l2/0046-UPSTREAM-media-videodev2.h-add-V4L2_CTRL_FLAG_DYNAMI.patch"
	"${FILESDIR}/v4l2/0047-BACKPORT-media-uapi-Move-parsed-HEVC-pixel-format-ou.patch"
	"${FILESDIR}/v4l2/0048-BACKPORT-media-uapi-Move-the-HEVC-stateless-control-.patch"
	"${FILESDIR}/v4l2/0049-BACKPORT-media-uapi-move-HEVC-stateless-controls-out.patch"
	# Above patches from before and up to v6.1
	"${FILESDIR}/v4l2/0051-BACKPORT-media-add-Sorenson-Spark-video-format.patch"
	"${FILESDIR}/v4l2/0052-BACKPORT-media-add-RealVideo-format-RV30-and-RV40.patch"
	"${FILESDIR}/v4l2/0053-BACKPORT-media-uapi-HEVC-Add-num_delta_pocs_of_ref_r.patch"
	"${FILESDIR}/v4l2/0054-BACKPORT-media-Add-AV1-uAPI.patch"
	"${FILESDIR}/v4l2/0055-BACKPORT-FROMLIST-media-v4l2_ctrl-Add-V4L2_CTRL_TYPE.patch"
	"${FILESDIR}/v4l2/0056-BACKPORT-FROMLIST-v4l2-ctrls-add-support-for-V4L2_CT.patch"
	"${FILESDIR}/v4l2/0057-BACKPORT-FROMLIST-media-uvcvideo-implement-UVC-v1.5-.patch"
	# Above patches are from after v6.1

	# This is the end of the list. Please add new entries above this. Entries
	# below are expected to be removed soon.

	# Empty placeholder files for old *-ctrls-upstream.h header files
	# TODO (b/278157861) remove after header migration and inclusion removed
	# from Chromium
	"${FILESDIR}/v4l2/9998-CHROMIUM-v4l-Add-placeholder-header-files-for-split-.patch"
)

src_unpack() {
	# avoid kernel-2_src_unpack
	default
}

src_prepare() {
	# avoid kernel-2_src_prepare
	default
}

src_install() {
	kernel-2_src_install

	find "${ED}" \( -name '.install' -o -name '*.cmd' \) -delete || die
	# delete empty directories
	find "${ED}" -empty -type d -delete || die
}

src_test() {
	# Make sure no uapi/ include paths are used by accident.
	grep -E -r \
		-e '# *include.*["<]uapi/' \
		"${D}" && die "#include uapi/xxx detected"

	einfo "Possible unescaped attribute/type usage"
	grep -E -r \
		-e '(^|[[:space:](])(asm|volatile|inline)[[:space:](]' \
		-e '\<([us](8|16|32|64))\>' \
		.

	einfo "Missing linux/types.h include"
	grep -E -l -r -e '__[us](8|16|32|64)' "${ED}" | xargs grep -L linux/types.h

	emake ARCH="$(tc-arch-kernel)" headers_check
}
