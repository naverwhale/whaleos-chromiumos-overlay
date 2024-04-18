# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CHECKREQS_DISK_BUILD="4500M"
inherit autotools check-reqs linux-info mono-env pax-utils multilib-minimal

DESCRIPTION="Mono runtime and class libraries, a C# compiler/interpreter"
HOMEPAGE="https://mono-project.com"
SRC_URI="https://download.mono-project.com/sources/mono/${P}.tar.xz"

LICENSE="MIT LGPL-2.1 GPL-2 BSD-4 NPL-1.1 Ms-PL GPL-2-with-linking-exception IDPL"
SLOT="0"
KEYWORDS="-* amd64"
IUSE="doc nls pax-kernel xen"

DEPEND="
	app-crypt/mit-krb5[${MULTILIB_USEDEP}]
	sys-libs/zlib[${MULTILIB_USEDEP}]
	ia64? ( sys-libs/libunwind )
	nls? ( sys-devel/gettext )
"
RDEPEND="
	${DEPEND}
	app-misc/ca-certificates
"
BDEPEND="
	sys-devel/bc
	virtual/yacc
	pax-kernel? ( sys-apps/elfix )
"

PATCHES=(
	"${FILESDIR}"/${PN}-5.12-try-catch.patch
	"${FILESDIR}/mono-5.18.0-reference-assemblies-fix.patch"
	"${FILESDIR}/mono-5.18.0-use-mcs.patch"
	"${FILESDIR}/mono-6.6.0-roslyn-binaries.patch"
	"${FILESDIR}/mono-6.12.0.122-reference-assemblies-fix-v4.8-and-monowasm.patch"
)

pkg_pretend() {
	linux-info_pkg_setup

	if use kernel_linux ; then
		if linux_config_exists ; then
			linux_chkconfig_builtin SYSVIPC || die "SYSVIPC not enabled in the kernel"
		else
			# https://github.com/gentoo/gentoo/blob/f200e625bda8de696a28338318c9005b69e34710/eclass/linux-info.eclass#L686
			ewarn "kernel config not found"
			ewarn "If CONFIG_SYSVIPC is not set in your kernel .config, mono will hang while compiling."
			ewarn "See https://bugs.gentoo.org/261869 for more info."
		fi
	fi

	# bug #687892
	check-reqs_pkg_pretend
}

pkg_setup() {
	mono-env_pkg_setup
	check-reqs_pkg_setup
}

src_prepare() {
	# We need to sed in the paxctl-ng -mr in the runtime/mono-wrapper.in so it don't
	# get killed in the build process when MPROTECT is enabled, bug #286280
	# RANDMMAP kills the build process too, bug #347365
	# We use paxmark.sh to get PT/XT logic, bug #532244
	if use pax-kernel ; then
		ewarn "We are disabling MPROTECT on the mono binary."

		# issue 9 : https://github.com/Heather/gentoo-dotnet/issues/9
		sed '/exec "/ i\paxmark.sh -mr "$r/@mono_runtime@"' -i "${S}"/runtime/mono-wrapper.in || die "Failed to sed mono-wrapper.in"
	fi

	default

	# Remove directories with DLL/EXE binaries apart from the bare minimum:
	# * 'monolite-linux' used to build the compiler,
	# * 'binary-reference-assemblies' DLLs which will be rebuilt,
	# * 'mcs/class/Microsoft.Build.Tasks/Test/resources/binary'.
	rm -rf \
		external/helix-binaries \
		external/roslyn-binaries \
		mcs/class/lib/monolite-macos \
		mcs/class/lib/monolite-unix \
		mcs/class/lib/monolite-win32 \
		mcs/packages/mnt/jenkins || die

	# Don't build the internal mono-helix-client tool; requires helix-binaries.
	sed -i 's|mono-helix-client||g' mcs/tools/Makefile || die

	# PATCHES contains configure.ac patch
	eautoreconf
	multilib_copy_sources
}

multilib_src_configure() {
	local myeconfargs=(
		$(use_with xen xen_opt)
		--without-ikvm-native
		--disable-dtrace
		# The CXX, LDFLAGS etc. variables aren't respected in AOT compilation.
		--disable-system-aot
		# Roslyn can't be built from scratch.
		--with-csc=mcs
		$(use_with doc mcs-docs)
		$(use_enable nls)
	)

	econf "${myeconfargs[@]}"
}

multilib_src_compile() {
	emake

	# Rebuild the reference assemblies.
	cd external/binary-reference-assemblies || die
	emake clean
	export MONO_PATH="${BUILD_DIR}/mcs/class/lib/net_4_x-linux"
	emake V=1 CSC="${BUILD_DIR}/runtime/mono-wrapper ${MONO_PATH}/mcs.exe"
	unset MONO_PATH
}

multilib_src_test() {
	cd mcs/tests || die
	emake check
}

pkg_postinst() {
	# bug #762265
	cert-sync "${EROOT}"/etc/ssl/certs/ca-certificates.crt
}
