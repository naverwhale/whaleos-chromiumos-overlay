# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 )
inherit bash-completion-r1 estack eutils toolchain-funcs python-single-r1 linux-info

MY_PV="${PV/_/-}"
MY_PV="${MY_PV/-pre/-git}"

DESCRIPTION="Userland tools for Linux Performance Counters"
HOMEPAGE="https://perf.wiki.kernel.org/"

LINUX_V="${PV:0:1}.x"
if [[ ${PV} == *_rc* ]] ; then
	LINUX_VER=$(ver_cut 1-2).$(($(ver_cut 3)-1))
	PATCH_VERSION=$(ver_cut 1-3)
	LINUX_PATCH=patch-${PV//_/-}.xz
	SRC_URI="https://www.kernel.org/pub/linux/kernel/v${LINUX_V}/testing/${LINUX_PATCH}
		https://www.kernel.org/pub/linux/kernel/v${LINUX_V}/testing/v${PATCH_VERSION}/${LINUX_PATCH}"
elif [[ ${PV} == *.*.* ]] ; then
	# stable-release series
	LINUX_VER=$(ver_cut 1-2)
	LINUX_PATCH=patch-${PV}.xz
	SRC_URI="https://www.kernel.org/pub/linux/kernel/v${LINUX_V}/${LINUX_PATCH}"
else
	LINUX_VER=${PV}
	SRC_URI=""
fi

LINUX_SOURCES="linux-${LINUX_VER}.tar.xz"
SRC_URI+=" https://www.kernel.org/pub/linux/kernel/v${LINUX_V}/${LINUX_SOURCES}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="audit clang coresight crypt debug +demangle +doc gtk java lzma numa perl python slang systemtap unwind zlib zstd"
# TODO babeltrace
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="audit? ( sys-process/audit )
	crypt? ( dev-libs/openssl:0= )
	clang? (
		sys-devel/clang:*
		sys-devel/llvm:*
	)
	coresight? ( dev-libs/opencsd )
	gtk? ( x11-libs/gtk+:2 )
	java? ( virtual/jre:* )
	lzma? ( app-arch/xz-utils )
	numa? ( sys-process/numactl )
	perl? ( dev-lang/perl:= )
	python? ( ${PYTHON_DEPS} )
	slang? ( sys-libs/slang )
	systemtap? ( dev-util/systemtap )
	unwind? ( sys-libs/llvm-libunwind )
	zlib? ( sys-libs/zlib )
	zstd? ( app-arch/zstd )
	dev-libs/elfutils
	sys-libs/binutils-libs:="
DEPEND="${RDEPEND}
	>=sys-kernel/linux-headers-4.4"
BDEPEND="
	${LINUX_PATCH+dev-util/patchutils}
	sys-devel/bison
	sys-devel/flex
	java? ( virtual/jdk )
	doc? (
		app-text/asciidoc
		app-text/sgml-common
		app-text/xmlto
		sys-process/time
	)"

S_K="${WORKDIR}/linux-${LINUX_VER}"
S="${S_K}/tools/perf"

CONFIG_CHECK="~PERF_EVENTS ~KALLSYMS"

PATCHES=(
	"${FILESDIR}/5.3.7-Fix-hugepage-text.patch"
	"${FILESDIR}/5.3.7-Don-t-install-self-tests.patch"
	"${FILESDIR}/5.3.7-Fix-exit-on-signal.patch"
	"${FILESDIR}/5.3.7-Fix-libbfd-api.patch"
	"${FILESDIR}/5.3.7-Fix-configure-tests.patch"
	"${FILESDIR}/5.3.7-Update-perf-bench.patch"
	"${FILESDIR}/5.3.7-Fix-perf-bench.patch"
	"${FILESDIR}/5.3.7-Fix-nm-binutils-2.35.patch"
	"${FILESDIR}/5.3.7-cs-etm-Swap-packets.patch"
	"${FILESDIR}/5.3.7-cs-etm-Continuously-record-last-branch.patch"
	"${FILESDIR}/5.3.7-cs-etm-Correct-synth-inst-samples.patch"
	"${FILESDIR}/5.3.7-cs-etm-Optimize-copying-last-branches.patch"
	"${FILESDIR}/5.3.7-cs-etm-Fix-unsigned-variable.patch"
	"${FILESDIR}/5.3.7-cs-etm-Fix-definition-of-macro-TO_CS_QUEUE_NR.patch"
	"${FILESDIR}/5.3.7-cs-etm-Refactor-timestamp-variable-names.patch"
	"${FILESDIR}/5.3.7-cs-etm-Set-time-on-synthesised-samples-to-prese.patch"
	"${FILESDIR}/5.3.7-cs-etm-Delay-decode-of-non-timeless-data-until-cs_etm__flush_events.patch"
	"${FILESDIR}/5.3.7-Consolidate-symbol-fixup-issue.patch"
	"${FILESDIR}/5.3.7-Correct-event-attribute-sizes.patch"
	"${FILESDIR}/5.3.7-Fix-file-corruption-due-to-event-deletion.patch"
	"${FILESDIR}/5.3.7-Allow-no-CoreSight-sink.patch"
	"${FILESDIR}/5.3.7-EL2-fix-1-Update-ETM-metadata-format.patch"
	"${FILESDIR}/5.3.7-EL2-fix-2-Update-linux-coresight-pmu-h.patch"
	"${FILESDIR}/5.3.7-EL2-fix-3-Fix-bitmap-for-option.patch"
	"${FILESDIR}/5.3.7-EL2-fix-4-Support-PID-tracing-in-config.patch"
	"${FILESDIR}/5.3.7-EL2-fix-5-Add-cs-etm-helper.patch"
	"${FILESDIR}/5.3.7-EL2-fix-6-Detect-pid-in-VMID.patch"
	"${FILESDIR}/5.3.7-cs-etm-Move-synth_opts-initialisation.patch"
	"${FILESDIR}/5.3.7-auxtrace-Add-Z-itrace-option-for-timeless-decod.patch"
	"${FILESDIR}/5.3.7-cs-etm-Start-reading-Z-itrace-option.patch"
	"${FILESDIR}/5.3.7-cs-etm-Prevent-and-warn-on-underflows-during-ti.patch"
	"${FILESDIR}/5.3.7-session-Add-facility-to-peek-at-all-events.patch"
	"${FILESDIR}/5.3.7-cs-etm-Split-Coresight-decode-by-aux-records.patch"
)

pkg_setup() {
	linux-info_pkg_setup
	use python && python-single-r1_pkg_setup
}

src_unpack() {
	local paths=(
		tools/arch tools/build tools/include tools/lib tools/perf tools/scripts
		include lib "arch/*/lib"
	)
	local p1=(${paths[@]/%/*})

	# We expect the tar implementation to support the -j option (both
	# GNU tar and libarchive's tar support that).
	echo ">>> Unpacking ${LINUX_SOURCES} (${paths[*]}) to ${PWD}"
	tar --wildcards -xpf "${DISTDIR}"/${LINUX_SOURCES} \
		"${paths[@]/#/linux-${LINUX_VER}/}" || die

	if [[ -n ${LINUX_PATCH} ]] ; then
		eshopts_push -o noglob
		ebegin "Filtering partial source patch"
		xz -d -c "${DISTDIR}"/${LINUX_PATCH} | filterdiff -p1 ${p1[@]/#/-i } \
			> ${P}.patch
		eend $? || die "filterdiff failed"
		eshopts_pop
	fi

	local a
	for a in ${A}; do
		[[ ${a} == ${LINUX_SOURCES} ]] && continue
		[[ ${a} == ${LINUX_PATCH} ]] && continue
		unpack ${a}
	done

	# support clang8
	echo $(clang-major-version)
	if use clang; then
		local old_CC=${CC}
		CC=${CHOST}-clang
		if [[ $(clang-major-version) -ge 8 ]]; then
			pushd "${S_K}" >/dev/null || die
			eapply "${FILESDIR}/perf-5.1.15-fix-clang8.patch"
			popd || die
		fi
		CC=${old_CC}
	fi
}

src_prepare() {
	pushd "${S_K}" >/dev/null || die
	if [[ -n ${LINUX_PATCH} ]] ; then
		eapply "${WORKDIR}"/${P}.patch
	fi
	eapply ${PATCHES[@]}
	popd || die

	eapply_user

	# Drop some upstream too-developer-oriented flags and fix the
	# Makefile in general
	sed -i \
		-e 's:-Werror::' \
		-e "s:\$(sysconfdir_SQ)/bash_completion.d:$(get_bashcompdir):" \
		"${S}"/Makefile.perf || die
	# A few places still use -Werror w/out $(WERROR) protection.
	sed -i -e 's:-Werror::' \
		"${S}"/Makefile.perf "${S_K}"/tools/lib/bpf/Makefile || die

	# Avoid the call to make kernelversion
	echo "#define PERF_VERSION \"${MY_PV}\"" > PERF-VERSION-FILE

	# The code likes to compile local assembly files which lack ELF markings.
	find -name '*.S' -exec sed -i '$a.section .note.GNU-stack,"",%progbits' {} +
}

puse() { usex $1 "" no; }
perf_make() {
	# The arch parsing is a bit funky.  The perf tools package is integrated
	# into the kernel, so it wants an ARCH that looks like the kernel arch,
	# but it also wants to know about the split value -- i386/x86_64 vs just
	# x86.  We can get that by telling the func to use an older linux version.
	# It's kind of a hack, but not that bad ...

	# LIBDIR sets a search path of perf-gtk.so. Bug 515954

	local arch=$(tc-arch-kernel)
	local java_dir
	use java && java_dir="/etc/java-config-2/current-system-vm"
	use coresight && append-ldflags "-lc++" # opencsd requires linking with C++ libraries.

	MAKEOPTS="${MAKEOPTS} -j1" # crbug.com/1173859

	# FIXME: NO_LIBBABELTRACE
	# ChromeOS: Disable bpf support (https://crbug.com/1320051).
	emake V=1 VF=1 \
		CC="$(tc-getCC)" CXX="$(tc-getCXX)" AR="$(tc-getAR)" LD="$(tc-getLD)" \
		HOSTCC="$(tc-getBUILD_CC)" \
		PKG_CONFIG="$(tc-getPKG_CONFIG)" \
		prefix="${EPREFIX}/usr" bindir_relative="bin" \
		EXTRA_CFLAGS="${CFLAGS}" \
		ARCH="${arch}" \
		CORESIGHT=$(usex coresight 1 "") \
		JDIR="${java_dir}" \
		LIBCLANGLLVM=$(usex clang 1 "") \
		NO_AUXTRACE="" \
		NO_BACKTRACE="" \
		NO_DEMANGLE=$(puse demangle) \
		NO_GTK2=$(puse gtk) \
		NO_JVMTI=$(puse java) \
		NO_LIBAUDIT=$(puse audit) \
		NO_LIBBABELTRACE=1 \
		NO_LIBBIONIC=1 \
		NO_LIBBPF=1 \
		NO_LIBCRYPTO=$(puse crypt) \
		NO_LIBDW_DWARF_UNWIND="" \
		NO_LIBELF="" \
		NO_LIBNUMA=$(puse numa) \
		NO_LIBPERL=$(puse perl) \
		NO_LIBPYTHON=$(puse python) \
		NO_LIBUNWIND=$(puse unwind) \
		NO_SDT=$(puse systemtap) \
		NO_SLANG=$(puse slang) \
		NO_LZMA=$(puse lzma) \
		NO_LIBZSTD=$(puse zstd) \
		NO_ZLIB= \
		WERROR=0 \
		XMLTO="$(usex doc xmlto '')" \
		LIBDIR="/usr/libexec/perf-core" \
		"$@"
}

src_compile() {
	# test-clang.bin not build with g++
	if use clang; then
		pushd "${S_K}/tools/build/feature/" || die
		make V=1 CXX=${CHOST}-clang++ test-clang.bin || die
		popd
	fi
	perf_make -f Makefile.perf
	use doc && perf_make -C Documentation
}

src_test() {
	:
}

src_install() {
	perf_make -f Makefile.perf install DESTDIR="${D}"

	rm -rv "${ED}"/usr/share/doc/perf-tip || die

	if use gtk; then
		mv "${ED}"/usr/$(get_libdir)/libperf-gtk.so \
			"${ED}"/usr/libexec/perf-core || die
	fi

	dodoc CREDITS

	dodoc *txt Documentation/*.txt
	if use doc ; then
		docinto html
		dodoc Documentation/*.html
		doman Documentation/*.1
	fi
}

pkg_postinst() {
	if ! use doc ; then
		einfo "Without the doc USE flag you won't get any documentation nor man pages."
		einfo "And without man pages, you won't get any --help output for perf and its"
		einfo "sub-tools."
	fi
}
