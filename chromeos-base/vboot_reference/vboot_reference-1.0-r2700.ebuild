# Copyright 2012 The ChromiumOS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT=("ac2e1a752cdedb3879daa79a657cf4e1ffdd639c" "ae07277fe7394cbb60e746d21d17f2f0a1ac163b")
CROS_WORKON_TREE=("ee3130dd953a504240b2b60d7a1046af99bd99f3" "8d6f8fdce76674dc4f63f7b19f50a8b8b141218f")
PYTHON_COMPAT=( python3_{8..11} )

# platform2 is used purely for the platform2_test.py wrapper

CROS_WORKON_PROJECT=("chromiumos/platform/vboot_reference" "chromiumos/platform2")
CROS_WORKON_LOCALNAME=("platform/vboot_reference" "platform2")
CROS_WORKON_SUBTREE=("" "common-mk")
CROS_WORKON_DESTDIR=("${S}/vboot_reference" "${S}/platform2")

inherit cros-debug cros-fuzzer cros-sanitizers cros-workon cros-constants python-any-r1

DESCRIPTION="Chrome OS verified boot tools"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="cros_host dev_debug_force fuzzer pd_sync test tpmtests tpm tpm_dynamic tpm2 tpm2_simulator vtpm_proxy +flashrom"

REQUIRED_USE="
	tpm_dynamic? ( tpm tpm2 )
	!tpm_dynamic? ( ?? ( tpm tpm2 ) )
"

COMMON_DEPEND="
	chromeos-base/crosid:=
	app-arch/libarchive:=
	dev-libs/libzip:=
	dev-libs/nss:=
	dev-libs/openssl:=
	sys-apps/coreboot-utils:=
	flashrom? ( sys-apps/flashrom:= )
	sys-apps/util-linux:="
RDEPEND="${COMMON_DEPEND}"
# vboot_reference tests are shell scripts using all these utilities
DEPEND="
	${COMMON_DEPEND}
	test? (
		${PYTHON_DEPS}
		app-editors/vim-core
		app-shells/bash
		dev-libs/openssl
		sys-apps/coreutils
		sys-apps/diffutils
		sys-apps/grep
		sys-apps/sed
		sys-devel/bc
		virtual/awk
	)
"

get_build_dir() {
	echo "${S}/build-main"
}

src_configure() {
	# Determine sanitizer flags. This is necessary because the Makefile
	# purposely ignores CFLAGS from the environment. So we collect the
	# sanitizer flags and pass just them to the Makefile explicitly.
	SANITIZER_CFLAGS=
	append-flags() {
		SANITIZER_CFLAGS+=" $*"
	}
	sanitizers-setup-env
	if use_sanitizers; then
		# Disable alignment sanitization, https://crbug.com/1015908 .
		SANITIZER_CFLAGS+=" -fno-sanitize=alignment"

		# Run sanitizers with useful log output.
		SANITIZER_CFLAGS+=" -DVBOOT_DEBUG"

		# Suppressions for unit tests.
		if use test; then
			# Do not check memory leaks or odr violations in address sanitizer.
			# https://crbug.com/1015908 .
			export ASAN_OPTIONS+=":detect_leaks=0:detect_odr_violation=0:"
			# Suppress array bound checks, https://crbug.com/1082636 .
			SANITIZER_CFLAGS+=" -fno-sanitize=array-bounds"
		fi
	fi
	cros-debug-add-NDEBUG
	default
}

vemake() {
	emake -C "${S}/vboot_reference" \
		SRCDIR="${S}/vboot_reference" \
		LIBDIR="$(get_libdir)" \
		ARCH="$(tc-arch)" \
		SDK_BUILD=$(usev cros_host) \
		TPM2_MODE=$(usev tpm2) \
		PD_SYNC=$(usev pd_sync) \
		DEV_DEBUG_FORCE=$(usev dev_debug_force) \
		TPM2_SIMULATOR="$(usev tpm2_simulator)" \
		VTPM_PROXY="$(usev vtpm_proxy)" \
		FUZZ_FLAGS="${SANITIZER_CFLAGS}" \
		BUILD="$(get_build_dir)" \
		USE_FLASHROM="$(usev flashrom)" \
		"$@"
}

src_compile() {
	mkdir "$(get_build_dir)"
	tc-export CC AR CXX PKG_CONFIG
	# vboot_reference knows the flags to use
	unset CFLAGS
	vemake all $(usex fuzzer fuzzers '')
}

src_test() {
	! use amd64 && ! use x86 && ewarn "Skipping unittests for non-x86" && return 0

	# Supply a test wrapper, platform2_test.py. vboot_reference test scripts use
	# 'BUILD_RUN' for the build dir inside the wrapper. platform2_test would
	# filter that out of the environment so we ensure that it gets through using
	# --env.
	RUNTEST="${S}/platform2/common-mk/platform2_test.py --action=run"
	RUNTEST+=" $(usex cros_host --host --sysroot="${SYSROOT}")"
	RUNTEST+=" --env=BUILD_RUN=\${BUILD_RUN} --"
	vemake \
		RUNTEST="${RUNTEST}" \
		runtests
}

src_install() {
	einfo "Installing programs"
	vemake \
		DESTDIR="${D}" \
		install install_dev

	if use tpmtests; then
		into /usr
		# copy files starting with tpmtest, but skip .d files.
		dobin "$(get_build_dir)"/tests/tpm_lite/tpmtest*[^.]?
		dobin "$(get_build_dir)"/utility/tpm_set_readsrkpub
	fi

	if use fuzzer; then
		einfo "Installing fuzzers"
		local fuzzer_component_id="167186"
		fuzzer_install "${S}"/vboot_reference/OWNERS "$(get_build_dir)"/tests/cgpt_fuzzer \
			--comp "${fuzzer_component_id}"
		fuzzer_install "${S}"/vboot_reference/OWNERS "$(get_build_dir)"/tests/vb2_keyblock_fuzzer \
			--comp "${fuzzer_component_id}"
		fuzzer_install "${S}"/vboot_reference/OWNERS "$(get_build_dir)"/tests/vb2_preamble_fuzzer \
			--comp "${fuzzer_component_id}"
	fi
}
