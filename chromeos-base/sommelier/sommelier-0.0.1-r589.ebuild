# Copyright 2020 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT="ae07277fe7394cbb60e746d21d17f2f0a1ac163b"
CROS_WORKON_TREE=("8d6f8fdce76674dc4f63f7b19f50a8b8b141218f" "f0d10869ed442d2e48c4b48cadabb8485d86df2f" "f91b6afd5f2ae04ee9a2c19109a3a4a36f7659e6")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_SUBTREE="common-mk vm_tools/sommelier .gn"

PLATFORM_SUBDIR="vm_tools/sommelier"

inherit cros-workon platform

DESCRIPTION="A Wayland compositor for use in CrOS VMs"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/vm_tools/sommelier"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="kvm_guest"

# This ebuild should only be used on VM guest boards.
REQUIRED_USE="kvm_guest"

COMMON_DEPEND="
	dev-libs/libevdev:=
	x11-libs/libxkbcommon:=
	x11-libs/libxcb:=
	x11-libs/pixman:=
	x11-libs/libdrm:=
	dev-libs/wayland:=
	|| (
		media-libs/mesa:=[gbm]
		media-libs/minigbm:=
	)
	!fuzzer? (
		x11-base/xwayland:=
	)
"

RDEPEND="
	!<chromeos-base/vm_guest_tools-0.0.2-r722
	${COMMON_DEPEND}
"

DEPEND="
	${COMMON_DEPEND}
	chromeos-base/perfetto
	dev-util/meson
	dev-util/ninja
"

BDEPEND="
	${COMMON_DEPEND}
	dev-python/jinja
"

src_install() {
	platform_src_install

	dobin "${OUT}"/sommelier

	# TODO(sidereal) This fuzzer isn't useful without a re-design
	# of sommelier's error handling and memory management. Disable
	# it for now.
	# platform_fuzzer_install "${S}"/OWNERS "${OUT}"/sommelier_wayland_fuzzer
}

platform_pkg_test() {
	local tests=(
		sommelier_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done

	# Ensure the meson build script continues to work.
	if ! use x86 && ! use amd64 ; then
		elog "Skipping meson tests on non-x86 platform"
	else
		meson tmp_build_dir -Dgamepad=true -Dtracing=true -Dcommit_loop_fix=true \
				-Dblack_screen_fix=true -Dwith_tests=true \
				|| die "Failed to configure meson build"
		ninja -C tmp_build_dir || die "Failed to build sommelier with meson"
		[ -f tmp_build_dir/sommelier ] || die "Target 'sommelier' was not built by meson"
		platform_test "run" tmp_build_dir/sommelier_test || die "Tests failed"
	fi
}
