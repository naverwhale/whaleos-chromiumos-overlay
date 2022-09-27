# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: cros-rust.eclass
# @MAINTAINER:
# The Chromium OS Authors <chromium-os-dev@chromium.org>
# @BUGREPORTS:
# Please report bugs via https://crbug.com/new (with component "Tools>ChromeOS-Toolchain")
# @VCSURL: https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay/+/master/eclass/@ECLASS@
# @BLURB: Eclass for fetching, building, and installing Rust packages.

if [[ -z ${_ECLASS_CROS_RUST} ]]; then
_ECLASS_CROS_RUST="1"

# Check for EAPI 6+.
case "${EAPI:-0}" in
[012345]) die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
esac

# @ECLASS-VARIABLE: CROS_RUST_CRATE_NAME
# @DESCRIPTION:
# The name of the crate used by Cargo. This defaults to the package name.
: "${CROS_RUST_CRATE_NAME:=${PN}}"

# @ECLASS-VARIABLE: CROS_RUST_CRATE_VERSION
# @DESCRIPTION:
# The version of the crate used by Cargo. This defaults to PV. Note that
# cros-rust_get_crate_version can be used to get this information from the
# Cargo.toml but that is only available in src_* functions. Also, for -9999
# ebuilds this is handled in a special way; A symbolic link is used to point to
# the installed crate so it can be removed correctly.
: "${CROS_RUST_CRATE_VERSION:=${PV}}"

# @ECLASS-VARIABLE: CROS_RUST_EMPTY_CRATE
# @PRE_INHERIT
# @DESCRIPTION:
# Indicates that this package is an empty crate for satisfying cargo's
# requirements but will not actually be used during compile time.  Used by
# dev-dependencies or crates like winapi.
: "${CROS_RUST_EMPTY_CRATE:=}"

# @ECLASS-VARIABLE: CROS_RUST_EMPTY_CRATE_FEATURES
# @PRE_INHERIT
# @DESCRIPTION:
# Array of Cargo features emitted into the Cargo.toml of an empty crate. Allows
# downstream crates to depend on this crate with the given features enabled.
if [[ ! -v CROS_RUST_EMPTY_CRATE_FEATURES ]]; then
	CROS_RUST_EMPTY_CRATE_FEATURES=()
fi

# @ECLASS-VARIABLE: CROS_RUST_OVERFLOW_CHECKS
# @PRE_INHERIT
# @DESCRIPTION:
# Enable integer overflow checks for this package.  Packages that wish to
# disable integer overflow checks should set this value to 0.  Integer overflow
# checks are always enabled when the cros-debug flag is set.
: "${CROS_RUST_OVERFLOW_CHECKS:=1}"

# @ECLASS-VARIABLE: CROS_RUST_REMOVE_DEV_DEPS
# @PRE_INHERIT
# @DESCRIPTION:
# Removes all the dev-dependencies from the Cargo.toml. This can break circular
# dependencies and help minimize how many dependent packages need to be added.
: "${CROS_RUST_REMOVE_DEV_DEPS:=}"

# @ECLASS-VARIABLE: CROS_RUST_REMOVE_TARGET_CFG
# @PRE_INHERIT
# @DESCRIPTION:
# Removes all the target. sections from the Cargo.toml except cfg(unix),
# cfg(linux), cfg(not(windows), and *-linux-gnu. Note that this does not handle
# more complicated cfg strings, so those cases should be handled manually
# instead of using this option.
: "${CROS_RUST_REMOVE_TARGET_CFG:=}"

# @ECLASS-VARIABLE: CROS_RUST_SUBDIR
# @DESCRIPTION:
# Subdir where the package is located. Only used by cros-workon ebuilds.
: "${CROS_RUST_SUBDIR:=${CROS_RUST_CRATE_NAME}}"

# @ECLASS-VARIABLE: CROS_RUST_TESTS
# @DESCRIPTION:
# An array of test executables to be run, which defaults to empty value and is
# set by invoking cros-rust_get_test_executables.
: "${CROS_RUST_TESTS:=}"

# @ECLASS-VARIABLE: CROS_RUST_HOST_TESTS
# @DESCRIPTION:
# An array of test executables that are built for cros-host, which defaults to
# empty value and is set by invoking cros-rust_get_host_test_executables.
# If it is empty when cros-rust_get_test_executables is called, it will be set
# to include tests not compiled for ${CHOST}.
: "${CROS_RUST_HOST_TESTS:=}"

# @ECLASS-VARIABLE: CROS_RUST_PLATFORM_TEST_ARGS
# @DESCRIPTION:
# An array of arguments to pass to platform2_test.py such as --no-ns-net,
# --no-ns-pid, or --run_as_root.

# @ECLASS-VARIABLE: CROS_RUST_TEST_DIRECT_EXEC_ONLY
# @DESCRIPTION:
# If set to yes, run the test only for amd64 and x86 (i.e. no emulation).
: "${CROS_RUST_TEST_DIRECT_EXEC_ONLY:="no"}"

inherit multiprocessing toolchain-funcs cros-constants cros-debug cros-sanitizers

IUSE="amd64 asan cros_host fuzzer lsan +lto msan sccache test tsan ubsan x86"
REQUIRED_USE="?? ( asan lsan msan tsan )"

EXPORT_FUNCTIONS pkg_setup src_unpack src_prepare src_configure src_compile src_test src_install pkg_preinst pkg_postinst pkg_prerm

DEPEND="
	>=virtual/rust-1.39.0:=
"

ECARGO_HOME="${WORKDIR}/cargo_home"
CROS_RUST_REGISTRY_BASE="/usr/lib/cros_rust_registry"
CROS_RUST_REGISTRY_DIR="${CROS_RUST_REGISTRY_BASE}/store"
CROS_RUST_REGISTRY_INST_DIR="${CROS_RUST_REGISTRY_BASE}/registry"

# Ignore odr violations in unit tests in asan builds
# (https://github.com/rust-lang/rust/issues/41807).
export ASAN_OPTIONS="detect_odr_violation=0"

# @FUNCTION: cros-rust_get_reg_lock
# @DESCRIPTION:
# Return the path to the rust registry lock file used to prevent races. A
# function is required to support binary packages shared across boards by moving
# the reference to PORTAGE_TMPDIR out of global scope.
cros-rust_get_reg_lock() {
	echo "${PORTAGE_TMPDIR}/cros-rust-registry/lock"
}

# @FUNCTION: cros-rust_get_sccache_dir
# @DESCRIPTION:
# Return the path to the directory used for the sccache cache. This cannot be in
# global scope for the reason above.
cros-rust_get_sccache_dir() {
	echo "${PORTAGE_TMPDIR}/sccache"
}

# @FUNCTION: cros-rust_pkg_setup
# @DESCRIPTION:
# Sets up the package. Particularly, makes sure the rust registry lock exits.
cros-rust_pkg_setup() {
	debug-print-function "${FUNCNAME[0]}" "$@"
	# This triggers a linter error SC2154 which says:
	#   "EBUILD_PHASE_FUNC is used but not defined inside this file"
	# Since EBUILD_PHASE_FUNC comes from outside the file, that's ok
	# shellcheck disable=SC2154
	if [[ "${EBUILD_PHASE_FUNC}" != "pkg_setup" ]]; then
		die "${FUNCNAME[0]}() should only be used in pkg_setup() phase"
	fi
	_cros-rust_prepare_lock "$(cros-rust_get_reg_lock)"

	# This is needed for CROS_WORKON_INCREMENTAL_BUILD to be honored.
	if [[ -n "${CROS_WORKON_PROJECT}" ]]; then
		cros-workon_pkg_setup
	fi

	local sccache_dir="$(cros-rust_get_sccache_dir)"
	addwrite "${sccache_dir}"
	mkdir -p "${sccache_dir}"
	chmod 755 "${sccache_dir}"
	chown "${PORTAGE_USERNAME}:${PORTAGE_GRPNAME}" "${sccache_dir}" "${sccache_dir%/*}"
}

# @FUNCTION: cros-rust_src_unpack
# @DESCRIPTION:
# Unpacks the package
cros-rust_src_unpack() {
	debug-print-function "${FUNCNAME[0]}" "$@"

	# If this is a cros-workon ebuild and hasn't been unpacked, then unpack it.
	if [[ -n "${CROS_WORKON_PROJECT}" && ! -e "${S}" ]]; then
		cros-workon_src_unpack
		S+="/${CROS_RUST_SUBDIR}"
	fi

	local archive
	for archive in ${A}; do
		case "${archive}" in
			*.crate)
				ebegin "Unpacking ${archive}"

				ln -s "${DISTDIR}/${archive}" "${archive}.tar"
				unpack "./${archive}.tar"
				rm "${archive}.tar"

				eend $?
				;;
			*)
				unpack "${archive}"
				;;
		esac
	done

	if [[ "${CROS_RUST_EMPTY_CRATE}" == "1" ]]; then
		# Generate an empty Cargo.toml and src/lib.rs for this crate.
		mkdir -p "${S}/src"
		cat <<- EOF >> "${S}/Cargo.toml"
		[package]
		name = "${CROS_RUST_CRATE_NAME}"
		version = "${CROS_RUST_CRATE_VERSION}"
		authors = ["The Chromium OS Authors"]

		[features]
		EOF

		if [[ "$(declare -p CROS_RUST_EMPTY_CRATE_FEATURES 2> /dev/null)" != "declare -a"* ]]; then
			eerror "CROS_RUST_EMPTY_CRATE_FEATURES must be an array"
			die
		fi

		local feature
		for feature in "${CROS_RUST_EMPTY_CRATE_FEATURES[@]}"; do
			echo "${feature} = []" >> "${S}/Cargo.toml"
		done

		touch "${S}/src/lib.rs"
	fi

	# Set up the cargo config.
	mkdir -p "${ECARGO_HOME}"

	cat <<- EOF > "${ECARGO_HOME}/config"
	[source.chromeos]
	directory = "${SYSROOT}${CROS_RUST_REGISTRY_INST_DIR}"

	[source.crates-io]
	replace-with = "chromeos"
	local-registry = "/nonexistent"

	[build]
	jobs = $(makeopts_jobs)

	[target.${CHOST}]
	linker = "$(tc-getCC)"
	EOF

	# When the target environment is different from the host environment,
	# add a setting for the target environment.
	if tc-is-cross-compiler; then
		cat <<- EOF >> "${ECARGO_HOME}/config"

		[target.${CBUILD}]
		linker = "$(tc-getBUILD_CC)"
		EOF
	fi

	# Tell cargo not to use terminal colors if NOCOLOR is set.
	if [[ "${NOCOLOR}" == true || "${NOCOLOR}" == yes ]]; then
		cat <<- EOF >> "${ECARGO_HOME}/config"

		[term]
		color = "never"
		EOF
	fi
}

# @FUNCTION: cros-rust_src_prepare
# @DESCRIPTION:
# Prepares the src. This function supports "# provided by ebuild" macro and
# "# ignored by ebuild" macro for replacing and removing path dependencies
# with ones provided by their ebuild in Cargo.toml
# and Cargo.toml will be modified in place. If the macro is used in
# ${S}/Cargo.toml, CROS_WORKON_OUTOFTREE_BUILD can't be set to 1 in its ebuild.
cros-rust_src_prepare() {
	debug-print-function "${FUNCNAME[0]}" "$@"
	if grep -q "# provided by ebuild" "${S}/Cargo.toml"; then
		# This triggers a linter error SC2154 which says:
		#   "CROS_WORKON_OUTOFTREE_BUILD is used but not defined inside this file"
		# Since CROS_WORKON_OUTOFTREE_BUILD comes from outside the file, that's ok
		# shellcheck disable=SC2154
		if [[ "${CROS_WORKON_OUTOFTREE_BUILD}" == 1 ]]; then
			die "CROS_WORKON_OUTOFTREE_BUILD=1 must not be set when using" \
				"\`provided by ebuild\`"
		fi

		# Replace path dependencies with ones provided by their ebuild.
		#
		# For local developer builds, we want Cargo.toml to contain path
		# dependencies on sibling crates within the same repository or elsewhere
		# in the Chrome OS source tree. This enables developers to run `cargo
		# build` and have dependencies resolve correctly to their locally
		# checked out code.
		#
		# At the same time, some crates contained within the crosvm repository
		# have their own ebuild independent of the crosvm ebuild so that they
		# are usable from outside of crosvm. Ebuilds of downstream crates won't
		# be able to depend on these crates by path dependency because that
		# violates the build sandbox. We perform a sed replacement to eliminate
		# the path dependency during ebuild of the downstream crates.
		#
		# The sed command says: in any line containing `# provided by ebuild`,
		# please replace `path = "..."` with `version = "*"`. The intended usage
		# is like this:
		#
		#     [dependencies]
		#     data_model = { path = "../data_model" }  # provided by ebuild
		#
		sed -i \
			'/# provided by ebuild$/ s/path = "[^"]*"/version = "*"/' \
			"${S}/Cargo.toml" || die
	fi

	if grep -q "# ignored by ebuild" "${S}/Cargo.toml"; then
		if [[ "${CROS_WORKON_OUTOFTREE_BUILD}" == 1 ]]; then
			die "CROS_WORKON_OUTOFTREE_BUILD=1 must not be set when using" \
				"\`ignored by ebuild\`"
		fi
		# Emerge ignores "out-of-sandbox" [patch.crates-io] lines in
		# Cargo.toml.
		sed -i \
			'/# ignored by ebuild/d' \
			"${S}/Cargo.toml" || die
	fi

	# Remove dev-dependencies and target.cfg sections within the Cargo.toml file
	#
	# The awk program reads the file line by line. If any line matches one of the
	# matched section headers, it will skip every line a new section header is
	# found that does not match one of the matched section headers.
	#
	# Awk cannot do in-place editing, so we write the result to a temporary
	# file before replacing the input with that temp file.
	if [[ "${CROS_RUST_REMOVE_DEV_DEPS}" == 1 ]] || [[ "${CROS_RUST_REMOVE_TARGET_CFG}" == 1 ]]; then
		awk -v rm_dev_dep="${CROS_RUST_REMOVE_DEV_DEPS}" \
		-v rm_target_cfg="${CROS_RUST_REMOVE_TARGET_CFG}" \
		'{
			# Stop skipping for a new section header, but check for another match.
			if ($0 ~ /^\[/) {
				skip = 0
			}

			# If rm_dev_dep is set, match section headers of the following forms:
			#   [token.dev-dependencies]
			#   [dev-dependencies.token]
			#   [dev-dependencies]
			if (rm_dev_dep && ($0 ~ /^\[([^][]+\.)?dev-dependencies(\.[^][]+)?\]$/)) {
				skip = 1
				next
			}

			# If rm_target_cfg is set, match section headers prefixed by `[target.`,
			# but exclude matches that contain any of `cfg(unix`, `cfg(linux`,
			# `cfg(not(windows)`, or `-linux-gnu`.
			if (rm_target_cfg && ($0 ~ /^\[target[.]/) && ($0 !~ /cfg[(](unix|linux|not[(]windows[)])|-linux-gnu/)) {
				skip = 1
				next
			}

			if (skip == 0) {
				print
			}
		}' "${S}/Cargo.toml" > "${S}/Cargo.toml.stripped" || die
		mv "${S}/Cargo.toml.stripped" "${S}/Cargo.toml"|| die
	fi

	default
}

# @FUNCTION: cros-rust_configure_cargo
# @DESCRIPTION:
# Sets up cargo configuration and exports any environment variables needed
# during the build.
cros-rust_configure_cargo() {
	debug-print-function "${FUNCNAME[0]}"
	sanitizers-setup-env
	cros-debug-add-NDEBUG

	if [[ -n "${CROS_WORKON_PROJECT}" ]]; then
		# Use a sub directory to avoid unintended interactions with platform.eclass.
		export CARGO_TARGET_DIR="$(cros-workon_get_build_dir)/cros-rust"
		mkdir -p "${CARGO_TARGET_DIR}"
	else
		export CARGO_TARGET_DIR="${WORKDIR}"
	fi
	export CARGO_HOME="${ECARGO_HOME}"
	export HOST="${CBUILD}"
	export HOST_CC="$(tc-getBUILD_CC)"
	# PKG_CONFIG_ALLOW_CROSS is required by pkg-config.
	# https://github.com/rust-lang/pkg-config-rs/issues/41.
	# Since cargo will overwrites $HOST with "" when building pkg-config, we
	# need to set it regardless of the value of tc-is-cross-compiler here.
	export PKG_CONFIG_ALLOW_CROSS=1
	export PKG_CONFIG="$(tc-getPKG_CONFIG)"
	export SCCACHE_DIR="$(cros-rust_get_sccache_dir)"
	export TARGET="${CHOST}"
	export TARGET_CC="$(tc-getCC)"

	# Intended use case:
	# - Crate A generates sources when it is emerged from input files
	#   that are only accessible when it emerges.
	# - Crate B depends on crate A, and this is reflected in the
	#   ebuild for crate B.
	# (Examples: cros-dbus-bindings or bindgen for *-sys)
	#
	# The following scenarios are supported and need to work:
	# - local `cargo build` for crate A
	# - local `cargo build` for crate B
	# - emerge A
	# - emerge B
	#
	# Add CROS_RUST environment variable to support the `emerge B`
	# case, since crate B can't access pre-generated source
	# in emerge, the build.rs script for crate A will skip the
	# source generation if both of the following are true:
	# - The generated source exists
	# - `CROS_RUST=1`
	export CROS_RUST="1"

	# There is a memory leak in libbacktrace:
	# https://github.com/rust-lang/rust/issues/59125
	cros-rust_use_sanitizers || export RUST_BACKTRACE=1

	# We want debug info even in release builds.
	local rustflags=(
		"${CROS_BASE_RUSTFLAGS}"
		-Cdebuginfo=2
		-Copt-level=3
	)

	if use lto
	then
		rustflags+=( -Clto=thin )
		# rustc versions >= 1.45 support -Cembed-bitcode, which Cargo sets to
		# no because it does not know that we want to use LTO.
		# Because -Clto requires -Cembed-bitcode=yes, set it explicitly.
		if [[ $(rustc --version | awk '{ gsub(/\./, ""); print $2 }') -ge 1450 ]]
		then
			rustflags+=( -Cembed-bitcode=yes )
		fi
	fi

	# We don't want to abort during tests.
	use test || rustflags+=( -Cpanic=abort )

	if use cros-debug || [[ "${CROS_RUST_OVERFLOW_CHECKS}" == "1" ]]; then
		rustflags+=( -Coverflow-checks=on )
	fi

	use cros-debug && rustflags+=( -Cdebug-assertions=on )

	# Rust compiler is not exporting the __asan_* symbols needed in
	# asan builds. Force export-dynamic linker flag to export __asan_* symbols
	# https://crbug.com/1085546
	use asan && rustflags+=( -Csanitizer=address -Clink-arg="-Wl,-export-dynamic" )
	use lsan && rustflags+=( -Csanitizer=leak )
	use msan && rustflags+=( -Csanitizer=memory -Clink-arg="-Wl,--allow-shlib-undefined")
	use tsan && rustflags+=( -Csanitizer=thread )
	use ubsan && rustflags+=( -Clink-arg=-fsanitize=undefined )

	if use fuzzer; then
		rustflags+=(
			--cfg fuzzing
			-Cpasses=sancov
			-Cllvm-args=-sanitizer-coverage-level=4
			-Cllvm-args=-sanitizer-coverage-inline-8bit-counters
			-Cllvm-args=-sanitizer-coverage-trace-compares
			-Cllvm-args=-sanitizer-coverage-pc-table
			-Cllvm-args=-sanitizer-coverage-trace-divs
			-Cllvm-args=-sanitizer-coverage-trace-geps
			-Cllvm-args=-sanitizer-coverage-prune-blocks=0
			-Clink-arg="-Wl,--no-gc-sections"
		)
	fi

	local sccache="/usr/bin/sccache"
	if use sccache; then
		export RUSTC_WRAPPER="${sccache}"
		addwrite "$(cros-rust_get_sccache_dir)"
	fi

	# Add EXTRA_RUSTFLAGS to the current rustflags. This lets us emerge rust
	# packages with locally exported flags for testing purposes as:
	# `EXTRA_RUSTFLAGS="<flags>" emerge-$BOARD <package>`
	rustflags+=( "${EXTRA_RUSTFLAGS:=}" )

	# Ensure RUSTFLAGS is *not* set in the environment.
	# If it is, it will override the flags we configure below. See:
	# https://doc.rust-lang.org/cargo/reference/config.html#buildrustflags
	# Ebuilds should set their custom rustflags in cargo configuration.
	# Developers can pass EXTRA_RUSTFLAGS for one-off builds as above.
	unset RUSTFLAGS

	# Add rustflags to the cargo configuration.
	# This [target] section will apply to *all* targets, CHOST and CBUILD.
	# TODO(dcallagh): some flags above are not applicable to all targets,
	# they should be configured into suitable [target] sections.
	# TODO(dcallagh): escape TOML values correctly instead of assuming
	# that no rustflags contain spaces or quotes.
	cat <<- EOF >> "${ECARGO_HOME}/config"

	[target.'cfg(all())']
	rustflags = "${rustflags[*]}"
	EOF
}

# @FUNCTION: cros-rust_update_cargo_lock
# @DESCRIPTION:
# Regenerates/removes the Cargo.lock file to ensure cargo uses the dependency
# versions from our local registry.
cros-rust_update_cargo_lock() {
	debug-print-function "${FUNCNAME[0]}"

	if [[ -n "${CROS_WORKON_PROJECT}" ]]; then
		# Force an update the Cargo.lock file.
		ecargo generate-lockfile
		if [[ "${CROS_WORKON_INCREMENTAL_BUILD}" == "1" ]]; then
			local previous_lockfile="${CARGO_TARGET_DIR}/Cargo.lock.prev"
			# If any of the dependencies have changed, clear the incremental results.
			if [[ ! -f "${previous_lockfile}" ]] ||
					! cmp Cargo.lock "${previous_lockfile}" ; then
				# This will print errors for the .crate files, but that is OK.
				rm -rf "${CARGO_TARGET_DIR}"
				mkdir -p "${CARGO_TARGET_DIR}"
				cp Cargo.lock "${previous_lockfile}" || die
			fi
		fi
	else
		# Remove 3rd party lockfiles.
		rm -f Cargo.lock
	fi
}

# @FUNCTION: cros-rust_src_configure
# @DESCRIPTION:
# Configures the source and exports any environment variables needed during the
# build.
cros-rust_src_configure() {
	debug-print-function "${FUNCNAME[0]}"
	cros-rust_configure_cargo
	cros-rust_update_cargo_lock
	default
}

# @FUNCTION: cros-rust_use_sanitizers
# @DESCRIPTION:
# Checks whether sanitizers are being used.
cros-rust_use_sanitizers() {
	use_sanitizers || use lsan
}

# @FUNCTION: ecargo
# @USAGE: <args to cargo>
# @DESCRIPTION:
# Call cargo with the specified command line options.
ecargo() {
	debug-print-function "${FUNCNAME[0]}" "$@"

	addwrite Cargo.lock

	# Acquire a shared (read only) lock since this does not modify the registry.
	flock --shared "$(cros-rust_get_reg_lock)" cargo -v "$@"
	local status="$?"

	# This needs to be executed on both success and failure.
	local sccache="/usr/bin/sccache"
	if use sccache; then
		sccache --stop-server
	fi

	if [[ "${status}" != 0 ]]; then
		die
	fi
}

# @FUNCTION: write_clippy
# @INTERNAL
# @DESCRIPTION:
# Executes cargo clippy and writes lints to file
_ecargo_write_clippy() {
	# TODO(crbug.com/1194200): we should stop using /tmp for this sort of thing
	local clippy_output_base="/tmp/cargo_clippy/${CATEGORY}"
	mkdir -p "${clippy_output_base}"

	# FIXME(crbug.com/1195313): rustc sysroot may not contain dependencies
	local sysroot_old="${SYSROOT}"
	SYSROOT=$(rustc --print sysroot)
	echo "{\"package_path\":\"${S}\"}" > "${clippy_output_base}/${PF}.json"
	ecargo clippy ---message-format json --target="${CHOST}" --release \
		--manifest-path="${S}/Cargo.toml" >> "${clippy_output_base}/${PF}.json"
	export SYSROOT="${sysroot_old}"
}

# @FUNCTION: ecargo_build
# @USAGE: <args to cargo build>
# @DESCRIPTION:
# Call `cargo build` with the specified command line options.
ecargo_build() {
	ecargo build --target="${CHOST}" --release "$@"
	# FIXME(b/191687433): refactor ENABLE_RUST_CLIPPY to be easier to enable/disable then remove the platform2 check
	if [[ -n "${ENABLE_RUST_CLIPPY}" && "${CROS_WORKON_PROJECT}" == "chromiumos/platform2" ]]; then
		_ecargo_write_clippy
	fi
}

# @FUNCTION: ecargo_build_fuzzer
# @DESCRIPTION:
# Call `cargo build` with fuzzing options enabled.
ecargo_build_fuzzer() {
	local fuzzer_libdir="$(dirname "$($(tc-getCC) -print-libgcc-file-name)")"
	local fuzzer_arch="${ARCH}"
	if [[ "${ARCH}" == "amd64" ]]; then
		fuzzer_arch="x86_64"
	fi

	local link_args=(
		-Clink-arg="-L${fuzzer_libdir}"
		-Clink-arg="-lclang_rt.fuzzer-${fuzzer_arch}"
		-Clink-arg="-lc++"
		-Clink-arg="-Wl,-export-dynamic"
	)

	# The `rustc` subcommand for cargo allows us to set some extra flags for
	# the current package without setting them for all `rustc` invocations.
	# On the other hand the flags in the RUSTFLAGS environment variable are set
	# for all `rustc` invocations.
	ecargo rustc --target="${CHOST}" --release "$@" -- "${link_args[@]}"
}

# @FUNCTION: cros_rust_platform_test
# @USAGE: <action> <bin> [-- [<test-args> ...]]
# @DESCRIPTION:
# Invokes platform2_test.py
cros_rust_platform_test() {
	local platform2_test_py="${CHROOT_SOURCE_ROOT}/src/platform2/common-mk/platform2_test.py"

	local action="$1"
	local bin="$2"
	if [[ "$#" -gt 2 && "$3" != "--" ]]; then
		die "Need to use -- to separate program args"
	fi

	local cmd=(
		"${platform2_test_py}"
		--action="${action}"
	)

	if use cros_host || has "${bin}" "${CROS_RUST_HOST_TESTS[@]}"; then
		cmd+=( "--host" )
		if [[ "${EAPI}" == "7" ]]; then
			cmd+=( --sysroot="${BROOT}" )
		fi
	else
		cmd+=( --sysroot="${SYSROOT}" )
	fi

	cmd+=( "${CROS_RUST_PLATFORM_TEST_ARGS[@]}" )

	if [[ -n "${bin}" ]]; then
		# $3 is "--" and anything that follows is passed to the test.
		cmd+=(
			"--"
			"${bin}"
			"${@:4}"
		)
	fi
	debug-print-function "${cmd[@]}"
	"${cmd[@]}" || die
}

# @FUNCTION: ecargo_test
# @USAGE: <args to cargo test>
# @DESCRIPTION:
# Call `cargo test` with the specified command line options.
ecargo_test() {
	local test_dir="${CARGO_TARGET_DIR}/ecargo-test"
	if has "--no-run" "$@"; then
		debug-print-function ecargo test --target="${CHOST}" --target-dir \
			"${test_dir}" --release "$@"
		ecargo test --target="${CHOST}" --target-dir "${test_dir}" --release "$@"
	else
		cros-rust_get_test_executables "$@"

		local x=0
		for (( x = 0; x <= $#; x++ )); do
			if [[ ${!x} == "--" ]]; then
				break
			fi
		done
		local test_args=( "${@:x}" )

		# Make sure there is a separator before --test-threads.
		if [[ "${#test_args[@]}" == 0 ]]; then
			test_args=( -- )
		fi

		# Limit the number of test threads if they are not limited already.
		if [[ " ${test_args[*]}" != *" --test-threads"* ]]; then
			test_args+=( "--test-threads=$(makeopts_jobs)" )
		fi

		local testfile
		for testfile in "${CROS_RUST_TESTS[@]}"; do
			cros_rust_platform_test run "${testfile}" "${test_args[@]}"
		done
	fi
}

# @FUNCTION: cros-rust_get_test_executables
# @USAGE: <args to cargo test>
# @DESCRIPTION:
# Call `ecargo_test` with '--no-run' and '--message-format=json' arguments.
# Then, use jq to parse and store all the test executables in a global array.
cros-rust_get_test_executables() {
	mapfile -t CROS_RUST_TESTS < \
		<(ecargo_test --no-run --message-format=json "$@" | \
		jq -r 'select(.profile.test == true) | .filenames[]')

	# Cargo puts tests not compiled for the SYSROOT in ecargo-test/release.
	if [[ -z "${CROS_RUST_HOST_TESTS}" ]]; then
		local testfile
		for testfile in "${CROS_RUST_TESTS[@]}"; do
			if [[ "${testfile}" == "${CARGO_TARGET_DIR}/ecargo-test/release"* ]]; then
				CROS_RUST_HOST_TESTS+=( "${testfile}" )
			fi
		done
	fi
}

# @FUNCTION: cros-rust_get_host_test_executables
# @USAGE: <args to cargo test>
# @DESCRIPTION:
# Call `ecargo_test` with '--no-run' and '--message-format=json' arguments.
# Then, use jq to parse and store the test executables in a global array.
cros-rust_get_host_test_executables() {
	mapfile -t CROS_RUST_HOST_TESTS < \
		<(ecargo_test --no-run --message-format=json "$@" | \
		jq -r 'select(.profile.test == true) | .filenames[]')
}

# @FUNCTION: cros-rust_publish
# @USAGE: [crate name] [crate version]
# @DESCRIPTION:
# Install a library crate to the local registry store.  Should only be called
# from within a src_install() function.
# This triggers a linter error SC2120 which says:
#   "rust_publish references arguments, but none are ever passed"
# In this case, we will use without arguments to get a default value, but other
# usages exist in other files that do use arguments, so there is no problem.
# shellcheck disable=SC2120
cros-rust_publish() {
	debug-print-function "${FUNCNAME[0]}" "$@"

	if [[ "${EBUILD_PHASE_FUNC}" != "src_install" ]]; then
		die "${FUNCNAME[0]}() should only be used in src_install() phase"
	fi

	local default_version="${CROS_RUST_CRATE_VERSION}"
	if [[ "${default_version}" == "9999" ]]; then
		# This triggers a linter error SC2119 which says:
		#   "Use foo "$@" if function's $1 should mean script's $1"
		# In this case, cros-rust_get_crate_version without arguments retrieves the
		# default value which is desired, so this warning can be ignored.
		# shellcheck disable=SC2119
		default_version="$(cros-rust_get_crate_version)"
	fi

	local name="${1:-${CROS_RUST_CRATE_NAME}}"
	local version="${2:-${default_version}}"

	# Create the .crate file.
	ecargo package --allow-dirty --no-metadata --no-verify || die

	# Unpack the crate we just created into the directory registry.
	local crate="${CARGO_TARGET_DIR}/package/${name}-${version}.crate"

	mkdir -p "${D}/${CROS_RUST_REGISTRY_DIR}"
	pushd "${D}/${CROS_RUST_REGISTRY_DIR}" > /dev/null || die
	tar xf "${crate}" || die

	# Calculate the sha256sum since cargo will want this later.
	local shasum="$(sha256sum "${crate}" | cut -d ' ' -f 1)"
	local dir="${name}-${version}"
	local checksum="${T}/${name}-${version}-checksum.json"

	# Calculate the sha256 hashes of all the files in the crate.
	# This triggers a linter error SC2207 which says:
	#   "Prefer mapfile or read -a to split command
	#    output (or quote to avoid splitting)."
	# In this case, cros-rust_get_crate_version no argument retrieves the
	# default value which is desired, so this warning can be ignored.
	# shellcheck disable=SC2207
	local files=( $(find "${dir}" -type f) )

	[[ "${#files[@]}" == "0" ]] && die "Could not find crate files for ${name}"

	# Now start filling out the checksum file.
	printf '{\n\t"package": "%s",\n\t"files": {\n' "${shasum}" > "${checksum}"
	local idx=0
	local f
	for f in "${files[@]}"; do
		shasum="$(sha256sum "${f}" | cut -d ' ' -f 1)"
		printf '\t\t"%s": "%s"' "${f#${dir}/}" "${shasum}" >> "${checksum}"

		# The json parser is unnecessarily strict about not allowing
		# commas on the last line so we have to track this ourselves.
		idx="$((idx+1))"
		if [[ "${idx}" == "${#files[@]}" ]]; then
			printf '\n' >> "${checksum}"
		else
			printf ',\n' >> "${checksum}"
		fi
	done
	printf "\t}\n}\n" >> "${checksum}"
	popd > /dev/null || die

	insinto "${CROS_RUST_REGISTRY_DIR}/${name}-${version}"
	newins "${checksum}" .cargo-checksum.json

	# We want the Cargo.toml.orig file to be world readable.
	fperms 0644 "${CROS_RUST_REGISTRY_DIR}/${name}-${version}/Cargo.toml.orig"

	# Symlink the 9999 version to the version installed by the crate.
	if [[ "${CROS_RUST_CRATE_VERSION}" == "9999" && "${version}" != "9999" ]]; then
		dosym "${name}-${version}" "${CROS_RUST_REGISTRY_DIR}/${name}-9999"
	fi
}

# @FUNCTION: cros-rust_get_build_dir
# @DESCRIPTION:
# Return the path to the directory where build artifacts are available.
cros-rust_get_build_dir() {
	echo "${CARGO_TARGET_DIR}/${CHOST}/release"
}

# @FUNCTION: cros_rust_is_direct_exec
# @DESCRIPTION:
# Return true if the compiled executables are expected to run on this platform.
cros_rust_is_direct_exec() {
	use amd64 || use x86
}

cros-rust_src_compile() {
	debug-print-function "${FUNCNAME[0]}" "$@"
	# Skip non cros-workon packages.
	[[ -z "${CROS_WORKON_PROJECT}" ]] && return 0

	ecargo_build "$@"
	use test && ecargo_test --no-run "$@"
}

cros-rust_src_test() {
	debug-print-function "${FUNCNAME[0]}" "$@"
	if [[ "${CROS_RUST_TEST_DIRECT_EXEC_ONLY}" == "yes" ]] && ! cros_rust_is_direct_exec; then
		ewarn "Skipping unittests for non-x86: ${PN}"
		return 0
	fi

	cros_rust_platform_test "pre_test"
	ecargo_test "$@"
	cros_rust_platform_test "post_test"
}

cros-rust_src_install() {
	debug-print-function "${FUNCNAME[0]}" "$@"

	# This triggers a linter error SC2119 which says:
	#   "Use cros-rust_publish "$@" if function's $1 should mean script's $1"
	# Here we will use without arguments to get a default value so there is no problem
	# shellcheck disable=SC2119
	cros-rust_publish
}

# @FUNCTION: _cros-rust_prepare_lock
# @INTERNAL
# @USAGE: <path to lock>
# @DESCRIPTION:
# Create the specified lock file. This should only be called inside pkg_*
# functions to ensure the lock file is owned by root. The permissions are set to
# 644 so that $PORTAGE_USERNAME:portage will be able to obtain a shared lock
# inside src_* functions.
_cros-rust_prepare_lock() {
	if [[ "$(id -u)" -ne 0 ]]; then
		die "_cros-rust_prepare_lock should only be called inside pkg_* functions."
	fi
	mkdir -p "$(dirname "$1")" || die
	chmod 755 "$(dirname "$1")" || die
	touch "$1" || die
	chmod 644 "$1" || die
}

# @FUNCTION: _cleanup_registry_link
# @INTERNAL
# @USAGE: [crate name] [crate version]
# @DESCRIPTION:
# Unlink a library crate from the local registry. This is repeated in the prerm
# and preinst stages.
_cleanup_registry_link() {
	local name="${1:-${CROS_RUST_CRATE_NAME}}"
	local version="${2:-${CROS_RUST_CRATE_VERSION}}"
	local crate="${name}-${version}"

	local crate_dir="${ROOT}${CROS_RUST_REGISTRY_DIR}/${crate}"
	if [[ "${version}" == "9999" && -L "${crate_dir}" ]]; then
		crate="$(basename "$(readlink -f "${crate_dir}")")"
	fi

	local registry_dir="${ROOT}${CROS_RUST_REGISTRY_INST_DIR}"
	local link="${registry_dir}/${crate}"
	# Add a check to avoid spamming when it doesn't exist (e.g. binary crates).
	if [[ -L "${link}" ]]; then
		einfo "Removing ${crate} from Cargo registry"
		# Acquire a exclusive lock since this modifies the registry.
		_cros-rust_prepare_lock "$(cros-rust_get_reg_lock)"
		# This triggers a linter error SC2016 which says:
		#   "Expressions don't expand in single quotes, use double quotes for that."
		# In this case, though, that is exactly what we want since we need the string
		# to be passed to sh without being evaluated first.
		# shellcheck disable=SC2016
		flock --no-fork --exclusive "$(cros-rust_get_reg_lock)" \
			sh -c 'rm -f "$0"' "${link}" || die
	fi
}

# @FUNCTION: cros-rust_pkg_preinst
# @USAGE: [crate name] [crate version]
# @DESCRIPTION:
# Make sure a library crate isn't linked in the local registry prior to the
# install step to avoid races.
cros-rust_pkg_preinst() {
	debug-print-function "${FUNCNAME[0]}" "$@"
	if [[ "${EBUILD_PHASE_FUNC}" != "pkg_preinst" ]]; then
		die "${FUNCNAME[0]}() should only be used in pkg_preinst() phase"
	fi

	_cleanup_registry_link "$@"
}

# @FUNCTION: cros-rust_pkg_postinst
# @USAGE: [crate name] [crate version]
# @DESCRIPTION:
# Install a library crate in the local registry store into the registry,
# making it visible to Cargo.
cros-rust_pkg_postinst() {
	debug-print-function "${FUNCNAME[0]}" "$@"
	if [[ "${EBUILD_PHASE_FUNC}" != "pkg_postinst" ]]; then
		die "${FUNCNAME[0]}() should only be used in pkg_postinst() phase"
	fi

	local name="${1:-${CROS_RUST_CRATE_NAME}}"
	local version="${2:-${CROS_RUST_CRATE_VERSION}}"
	local crate="${name}-${version}"

	local crate_dir="${ROOT}${CROS_RUST_REGISTRY_DIR}/${crate}"
	local registry_dir="${ROOT}${CROS_RUST_REGISTRY_INST_DIR}"

	if [[ "${version}" == "9999" && -L "${crate_dir}" ]]; then
		crate_dir="$(readlink -f "${crate_dir}")"
		crate="$(basename "${crate_dir}")"
	fi

	# Don't install links for binary-only crates as they won't have any
	# library crates to register.  This avoids dangling symlinks.
	if [[ -e "${crate_dir}" ]]; then
		local dest="${registry_dir}/${crate}"
		einfo "Linking ${crate} into Cargo registry at ${registry_dir}"
		mkdir -p "${registry_dir}"
		flock --no-fork --exclusive "$(cros-rust_get_reg_lock)" \
			ln -srT "${crate_dir}" "${dest}" || die
	fi
}

# @FUNCTION: cros-rust_pkg_prerm
# @USAGE: [crate name] [crate version]
# @DESCRIPTION:
# Unlink a library crate from the local registry.
cros-rust_pkg_prerm() {
	debug-print-function "${FUNCNAME[0]}" "$@"
	if [[ "${EBUILD_PHASE_FUNC}" != "pkg_prerm" ]]; then
		die "${FUNCNAME[0]}() should only be used in pkg_prerm() phase"
	fi

	_cleanup_registry_link "$@"
}

# @FUNCTION: cros-rust_get_crate_version
# @USAGE: <path to crate>
# @DESCRIPTION:
# Returns the version for a crate by finding the first 'version =' line in the
# Cargo.toml in the crate.
# This triggers a linter error SC2120 which says:
#   "rust_get_crate_version references arguments, but none are ever passed"
# In this case, we will use without arguments to get a default value, but other
# usages exist in other files that do use arguments, so there is no problem.
# shellcheck disable=SC2120
cros-rust_get_crate_version() {
	local crate="${1:-${S}}"
	[[ $# -gt 1 ]] && die "${FUNCNAME[0]}: incorrect number of arguments"
	awk '/^version = / { print $3 }' "${crate}/Cargo.toml" | head -n1 | tr -d '"'
}

fi
