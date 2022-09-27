# Copyright 2012 The Chromium OS Authors.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_PROJECT=(
	"chromiumos/platform/depthcharge"
	"chromiumos/platform/vboot_reference"
)

DESCRIPTION="coreboot's depthcharge payload"
HOMEPAGE="http://www.coreboot.org"
LICENSE="GPL-2"
KEYWORDS="~*"
IUSE="detachable fwconsole mocktpm pd_sync unibuild verbose debug
	physical_presence_power physical_presence_recovery"

# No pre-unibuild boards build firmware on ToT anymore.  Assume
# unibuild to keep ebuild clean.
REQUIRED_USE="unibuild"

DEPEND="
	sys-boot/coreboot:=
	chromeos-base/chromeos-ec-headers:=
	sys-boot/libpayload:=
	chromeos-base/chromeos-config:=
"

# While this package is never actually executed, we still need to specify
# RDEPEND. A binary version of this package could exist that was built using an
# outdated version of chromeos-config. Without the RDEPEND this stale binary
# package is considered valid by the package manager. This is problematic
# because we could have two binary packages installed having been build with
# different versions of chromeos-config. By specifying the RDEPEND we force
# the package manager to ensure the two versions use the same chromeos-config.
RDEPEND="${DEPEND}"

BDEPEND="
	dev-python/kconfiglib
"

CROS_WORKON_LOCALNAME=("../platform/depthcharge" "../platform/vboot_reference")
VBOOT_REFERENCE_DESTDIR="${S}/vboot_reference"
CROS_WORKON_DESTDIR=("${S}/depthcharge" "${VBOOT_REFERENCE_DESTDIR}")

# Don't strip to ease remote GDB use (cbfstool strips final binaries anyway)
STRIP_MASK="*"

inherit cros-workon cros-unibuild

# Build depthcharge with common options.
# Usage example: dc_make dev "${BUILD_DIR}" "${LIBPAYLOAD_DIR}"
# Args:
#   $1: Target to build
#   $2: Build directory to use.
#   $3: Directory where libpayload is located.
#   $4+: Any other Makefile arguments.
dc_make() {
	local target="$1"
	local builddir="$2"
	local libpayload="$3"

	shift 3

	local OPTS=(
		"EC_HEADERS=${SYSROOT}/usr/include/chromeos/ec"
		"VB_SOURCE=${VBOOT_REFERENCE_DESTDIR}"
		"PD_SYNC=$(usev pd_sync)"
		"LIBPAYLOAD_DIR=${libpayload}/libpayload"
		"obj=${builddir}"
	)

	use verbose && OPTS+=( "V=1" )
	use debug && OPTS+=( "SOURCE_DEBUG=1" )

	emake "${OPTS[@]}" \
		"${target}" \
		"$@"
}

# Build depthcharge for the current board.
# Builds the various output files for depthcharge:
#   depthcharge.elf   - normal image
#   dev.elf           - developer image
#   netboot.elf       - network image
# In addition, .map files are produced for each, and a .config file which
# holds the configuration that was used.
# Args
#   $1: board to build for.
#   $2: build directory
#   $3: libpayload dir
make_depthcharge() {
	local board="$1"
	local builddir="$2"
	local libpayload="$3"
	local base_defconfig="board/${board}/defconfig"
	local defconfig="${T}/${board}-defconfig"
	local config="${builddir}/depthcharge.config"

	if [[ -e "${base_defconfig}" ]]; then
		cp "${base_defconfig}" "${defconfig}"
	else
		ewarn "${base_defconfig} does not exist!"
		touch "${defconfig}"
	fi

	chmod +w "${defconfig}"

	if use mocktpm ; then
		echo "CONFIG_MOCK_TPM=y" >> "${defconfig}"
	fi
	if use fwconsole ; then
		echo "CONFIG_CLI=y" >> "${defconfig}"
		echo "CONFIG_SYS_PROMPT=\"${board}: \"" >> "${defconfig}"
	fi
	if use detachable ; then
		echo "CONFIG_DETACHABLE=y" >> "${defconfig}"
	fi

	if use physical_presence_power || use physical_presence_recovery ; then
		echo "CONFIG_PHYSICAL_PRESENCE_KEYBOARD=n" >> "${defconfig}"
	fi

	dc_make defconfig "${builddir}" "${libpayload}" \
		KBUILD_DEFCONFIG="${defconfig}" \
		DOTCONFIG="${config}"

	dc_make depthcharge "${builddir}" "${libpayload}" \
		DOTCONFIG="${config}"
	dc_make dev "${builddir}" "${libpayload}.gdb" \
		DOTCONFIG="${config}"
	dc_make netboot "${builddir}" "${libpayload}.gdb" \
		DOTCONFIG="${config}"
}

# Copy the fwconfig from libpayload to a path
# Args:
#    $1: libpayload dir
#    $2: depthcharge build directory
_copy_fwconfig() {
	local src="${1}/libpayload/include/static_fw_config.h"
	local dest="${2}/static_fw_config.h"

	if [[ -s "${src}" ]]; then
		cp "${src}" "${dest}"
		einfo "Copying ${src} into local tree"
	else
		ewarn "${src} does not exist"
	fi
}

src_compile() {
	local builddir
	local libpayload

	# Firmware related binaries are compiled with a 32-bit toolchain
	# on 64-bit platforms
	if use amd64 ; then
		export CROSS_COMPILE="i686-pc-linux-gnu-"
		export CC="${CROSS_COMPILE}gcc"
	else
		export CROSS_COMPILE=${CHOST}-
	fi

	pushd depthcharge >/dev/null || \
		die "Failed to change into ${PWD}/depthcharge"

		local name
		local depthcharge

	while read -r name && read -r depthcharge; do
		libpayload="${SYSROOT}/firmware/${name}/libpayload"
		builddir="$(cros-workon_get_build_dir)/${depthcharge}"
		mkdir -p "${builddir}"

		_copy_fwconfig "${libpayload}" "${builddir}"
		make_depthcharge "${depthcharge}" "${builddir}" "${libpayload}"
	done < <(cros_config_host get-firmware-build-combinations depthcharge)

	popd >/dev/null || die
}

do_install() {
	local board="$1"
	local builddir="$2"
	local dstdir="/firmware"

	if [[ -n "${build_target}" ]]; then
		dstdir+="/${build_target}"
		einfo "Installing depthcharge ${build_target} into ${dest_dir}"
	fi
	insinto "${dstdir}"

	pushd "${builddir}" >/dev/null || \
		die "couldn't access ${builddir}/ directory"

	local files_to_copy=(
		depthcharge.config
		{netboot,depthcharge,dev}.elf{,.map}
	)

	insinto "${dstdir}/depthcharge"
	doins "${files_to_copy[@]}"

	popd >/dev/null || die
}

src_install() {
	local build_target
	local builddir

	for build_target in $(cros_config_host \
			get-firmware-build-targets depthcharge); do
		builddir="$(cros-workon_get_build_dir)/${build_target}"

		do_install "${build_target}" "${builddir}"
	done
}
