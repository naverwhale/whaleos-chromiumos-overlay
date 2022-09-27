# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

# @ECLASS: cros-sanitizers.eclass
# @MAINTAINER:
# ChromeOS toolchain team <chromeos-toolchain@google.com>
# @DESCRIPTION:
# Ebuild helper functions for sanitizer builds on Chrome OS.

if [[ -z ${_CROS_SANITIZER_ECLASS} ]]; then
_CROS_SANITIZER_ECLASS=1

inherit flag-o-matic toolchain-funcs

IUSE="asan coverage fuzzer msan tsan ubsan"

# @FUNCTION: sanitizer-add-blocklist
# @DESCRIPTION:
# Add blocklist files to the sanitizer build flags.
sanitizer-add-blocklist() {
	if [[ $# -gt 1 ]]; then
		die "More than one argument passed."
	fi

	# Search blocklist files in source and files directories.
	local files_list=(
		"${FILESDIR}/sanitizer_blocklist.txt"
		"${S}/sanitizer_blocklist.txt"
	)
	# If a sanitizer name is passed, then search ${sanitizer}_blocklist.txt.
	if [[ $# -eq 1 ]]; then
		files_list+=(
			"${FILESDIR}/$1_blocklist.txt"
			"${S}/$1_blocklist.txt"
		)
	fi

	for blocklist_file in "${files_list[@]}"; do
		if [[ -f "${blocklist_file}" ]]; then
			append-flags "-fsanitize-blacklist=${blocklist_file}"
		fi
	done
}

# @FUNCTION: asan-setup-env
# @DESCRIPTION:
# Build a package with address sanitizer flags.
asan-setup-env() {
	use asan || return 0
	if ! tc-is-clang; then
		die "ASAN is only supported for clang"
	fi
	local asan_flags=(
		"-fsanitize=address"
	)
	append-flags "${asan_flags[@]}"
	append-ldflags "${asan_flags[@]}"
	sanitizer-add-blocklist "asan"
}

# @FUNCTION: coverage-setup-env
# @DESCRIPTION:
# Build a package with coverage flags.
coverage-setup-env() {
	use coverage || return 0
	append-flags -fprofile-instr-generate -fcoverage-mapping
	append-ldflags -fprofile-instr-generate -fcoverage-mapping
}

# @FUNCTION: msan-setup-env
# @DESCRIPTION:
# Build a package with memory sanitizer flags.
msan-setup-env() {
	use msan || return 0
	# msan does not work with FORTIFY enabled.
	append-cppflags "-U_FORTIFY_SOURCE"
	append-flags "-fsanitize=memory -fsanitize-memory-track-origins"
	append-ldflags "-fsanitize=memory"
	sanitizer-add-blocklist "msan"
}

# @FUNCTION: tsan-setup-env
# @DESCRIPTION:
# Build a package with thread sanitizer flags.
tsan-setup-env() {
	use tsan || return 0
	append-flags "-fsanitize=thread"
	append-ldflags "-fsanitize=thread"
	sanitizer-add-blocklist "tsan"
}

# @FUNCTION: ubsan-setup-env
# @DESCRIPTION:
# Build a package with undefined behavior sanitizer flags.
ubsan-setup-env() {
	use ubsan || return 0
	# Flags for normal ubsan builds.
	# TODO: Use same flags as fuzzer builds.
	local flags=(
		"-fsanitize=alignment,array-bounds,pointer-overflow,shift"
		"-fsanitize=integer-divide-by-zero,float-divide-by-zero"
		"-fsanitize=signed-integer-overflow,vla-bound"
		"-fno-sanitize=vptr"
		"-fno-sanitize-recover=all"
	)
	# Use different flags for fuzzer ubsan builds.
	if use fuzzer; then
		flags=(
			"-fsanitize=alignment,array-bounds,function,pointer-overflow"
			"-fsanitize=integer-divide-by-zero,float-divide-by-zero"
			"-fsanitize=signed-integer-overflow,shift,vla-bound,vptr"
			"-fno-sanitize-recover=all"
			"-frtti"
		)
	fi
	append-flags "${flags[@]}"
	append-ldflags "${flags[@]}"
	append-cppflags -DCHROMEOS_UBSAN_BUILD
	sanitizer-add-blocklist "ubsan"
}

# @FUNCTION: sanitizers-setup-env
# @DESCRIPTION:
# Build a package with required sanitizer flags.
sanitizers-setup-env() {
	asan-setup-env
	coverage-setup-env
	if [[ $(type -t fuzzer-setup-env) == "function" ]] ; then
		# Only run this if we've inherited cros-fuzzer.eclass.
		fuzzer-setup-env
	fi
	msan-setup-env
	tsan-setup-env
	ubsan-setup-env
}

# @FUNCTION: cros-rust-setup-sanitizers
# @DESCRIPTION:
# Sets up sanitizer flags for rust.
cros-rust-setup-sanitizers() {
	local rust_san_flags=()
	use asan && rust_san_flags+=( -Csanitizer=address )
	use lsan && rust_san_flags+=( -Csanitizer=leak )
	use msan && rust_san_flags+=( -Csanitizer=memory )
	use tsan && rust_san_flags+=( -Csanitizer=thread )

	export RUSTFLAGS="${rust_san_flags[*]}"
}

# @FUNCTION: use_sanitizers
# @DESCRIPTION:
# Checks whether sanitizers are being used.
# Also returns a true/false value when passed as arguments.
# Usage: use_sanitizers [trueVal] [falseVal]
use_sanitizers() {
	if use asan || use coverage || use fuzzer || use msan || use tsan || use ubsan; then
		[[ "$#" -eq 2 ]] && echo "$1"
		return 0
	fi

	[[ "$#" -eq 2 ]] && echo "$2"
	return 1
}

fi
