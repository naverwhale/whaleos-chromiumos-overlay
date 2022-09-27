# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Fast, dense and secure container management"
HOMEPAGE="https://linuxcontainers.org/lxd/introduction/"

# This list includes the subset of packages required for the LXD client library
# to build.
CROS_GO_PACKAGES=(
	"github.com/Rican7/retry"
	"github.com/Rican7/retry/backoff"
	"github.com/Rican7/retry/jitter"
	"github.com/Rican7/retry/strategy"
	"github.com/canonical/go-dqlite/client"
	"github.com/canonical/go-dqlite/driver"
	"github.com/canonical/go-dqlite/internal/bindings"
	"github.com/canonical/go-dqlite/internal/logging"
	"github.com/canonical/go-dqlite/internal/protocol"
	"github.com/flosch/pongo2"
	"github.com/gosexy/gettext"
	"github.com/juju/errors"
	"github.com/juju/loggo"
	"github.com/juju/webbrowser"
	"github.com/lxc/lxd/client"
	"github.com/lxc/lxd/lxd/db/cluster"
	"github.com/lxc/lxd/lxd/db/node"
	"github.com/lxc/lxd/lxd/db/query"
	"github.com/lxc/lxd/lxd/db/schema"
	"github.com/lxc/lxd/lxd/util"
	"github.com/lxc/lxd/shared/..."
	"github.com/mattn/go-colorable"
	"github.com/mattn/go-isatty"
	"github.com/mattn/go-sqlite3"
	"github.com/rogpeppe/fastuuid"
	"github.com/spf13/cobra"
	"github.com/spf13/pflag"
	"gopkg.in/errgo.v1"
	"gopkg.in/httprequest.v1"
	"gopkg.in/lxc/go-lxc.v2"
	"gopkg.in/macaroon-bakery.v2/bakery"
	"gopkg.in/macaroon-bakery.v2/bakery/checkers"
	"gopkg.in/macaroon-bakery.v2/bakery/internal/macaroonpb"
	"gopkg.in/macaroon-bakery.v2/httpbakery"
	"gopkg.in/macaroon-bakery.v2/internal/httputil"
	"gopkg.in/macaroon.v2"
	"gopkg.in/robfig/cron.v2"
)

CROS_GO_WORKSPACE="${S}/_dist"

LICENSE="Apache-2.0 BSD BSD-2 LGPL-2.1 LGPL-3 MIT MPL-2.0"
SLOT="0"
KEYWORDS="-* amd64 arm arm64"

IUSE="+daemon +ipv6 +dnsmasq nls test tools"

RESTRICT="test"

inherit autotools bash-completion-r1 cros-go linux-info multilib systemd user

SRC_URI="https://linuxcontainers.org/downloads/${PN}/${P}.tar.gz"

DEPEND="
	dev-db/sqlite
	dev-go/cmp
	dev-go/crypto
	dev-go/errors
	dev-go/genproto
	dev-go/glog
	dev-go/go-sys
	dev-go/httprouter
	dev-go/net
	dev-go/protobuf
	dev-go/text
	dev-go/websocket
	dev-lang/tcl
	>=dev-lang/go-1.9.4
	dev-libs/libuv
	dev-libs/protobuf:=
	nls? ( sys-devel/gettext )
	test? (
		app-misc/jq
		net-misc/curl
		sys-devel/gettext
	)
"

RDEPEND="
	daemon? (
		app-arch/xz-utils
		>=app-emulation/lxc-2.0.7:0[seccomp]
		dev-libs/libuv
		dev-libs/lzo
		dev-util/xdelta:3
		dnsmasq? (
			net-dns/dnsmasq[dhcp,ipv6?]
		)
		net-firewall/ebtables
		net-firewall/iptables[ipv6?]
		net-libs/libnfnetlink
		net-libs/libnsl:0=
		net-misc/rsync[xattr]
		sys-apps/iproute2[ipv6?]
		sys-fs/fuse
		sys-fs/lxcfs:0
		sys-fs/squashfs-tools
		virtual/acl
	)
"

CONFIG_CHECK="
	~BRIDGE
	~DUMMY
	~IP6_NF_NAT
	~IP6_NF_TARGET_MASQUERADE
	~IPV6
	~IP_NF_NAT
	~IP_NF_TARGET_MASQUERADE
	~MACVLAN
	~NETFILTER_XT_MATCH_COMMENT
	~NET_IPGRE
	~NET_IPGRE_DEMUX
	~NET_IPIP
	~NF_NAT_MASQUERADE_IPV4
	~NF_NAT_MASQUERADE_IPV6
	~VXLAN
"

ERROR_BRIDGE="BRIDGE: needed for network commands"
ERROR_DUMMY="DUMMY: needed for network commands"
ERROR_IP6_NF_NAT="IP6_NF_NAT: needed for network commands"
ERROR_IP6_NF_TARGET_MASQUERADE="IP6_NF_TARGET_MASQUERADE: needed for network commands"
ERROR_IPV6="IPV6: needed for network commands"
ERROR_IP_NF_NAT="IP_NF_NAT: needed for network commands"
ERROR_IP_NF_TARGET_MASQUERADE="IP_NF_TARGET_MASQUERADE: needed for network commands"
ERROR_MACVLAN="MACVLAN: needed for network commands"
ERROR_NETFILTER_XT_MATCH_COMMENT="NETFILTER_XT_MATCH_COMMENT: needed for network commands"
ERROR_NET_IPGRE="NET_IPGRE: needed for network commands"
ERROR_NET_IPGRE_DEMUX="NET_IPGRE_DEMUX: needed for network commands"
ERROR_NET_IPIP="NET_IPIP: needed for network commands"
ERROR_NF_NAT_MASQUERADE_IPV4="NF_NAT_MASQUERADE_IPV4: needed for network commands"
ERROR_NF_NAT_MASQUERADE_IPV6="NF_NAT_MASQUERADE_IPV6: needed for network commands"
ERROR_VXLAN="VXLAN: needed for network commands"

EGO_PN="github.com/lxc/lxd"

src_unpack() {
	unpack "${A}"
	cd "${S}"

	# Instead of using the lxd symlink in the dist directory, move the lxd
	# source into that directory. Otherwise, the cros-go_src_install stage
	# will fail since it won't traverse symlinks.
	rm "${S}/_dist/src/${EGO_PN}"
	mkdir "${S}/_dist/src/${EGO_PN}"
	find "${S}"/* -maxdepth 0 \
				-type d \
				! -name "_dist" \
				-exec mv {} "${S}/_dist/src/${EGO_PN}" \;
}

src_prepare() {
	cd "${S}/_dist/src/github.com/lxc/lxd"
	eapply "${FILESDIR}/${P}-Fix-lxd-import-error.patch" # crbug.com/1194406

	cd "${S}/_dist/src/${EGO_PN}"
	eapply "${FILESDIR}/0001-lxd-util-Add-HasFilesystem.patch" # crbug.com/1024327
	eapply "${FILESDIR}/0002-lxd-Detect-built-in-shiftfs-too.patch" # crbug.com/1024327
	eapply_user

	cd "${S}/_dist/deps/libco" || die "Can't cd to libco dir"
	eapply "${FILESDIR}/${P}-libco-arm-asm.patch"     # crbug.com/1059078
	eapply "${FILESDIR}/${P}-libco-aarch64-asm.patch" # crbug.com/1059078
	eapply "${FILESDIR}/${P}-libco-amd64-asm.patch"   # crbug.com/1059078

	cd "${S}/_dist/deps/raft" || die "Can't cd to raft dir"
	eautoreconf

	cd "${S}/_dist/deps/dqlite" || die "Can't cd to dqlite dir"
	eautoreconf
}

src_configure() {
	export GOPATH="${S}/_dist"
	cd "${GOPATH}/deps/sqlite" || die "Can't cd to sqlite dir"
	econf --enable-replication --disable-amalgamation --disable-tcl --libdir="${EPREFIX}/usr/$(get_libdir)/lxd"

	cd "${GOPATH}/deps/raft" || die "Can't cd to raft dir"
	PKG_CONFIG_PATH="${GOPATH}/deps/raft/" econf --libdir="${EPREFIX}/usr/$(get_libdir)/lxd"

	cd "${GOPATH}/deps/dqlite" || die "Can't cd to dqlite dir"
	export RAFT_CFLAGS="-I${GOPATH}/deps/raft/include/"
	export RAFT_LIBS="${GOPATH}/deps/raft/.libs"
	export CO_CFLAGS="-I${GOPATH}/deps/libco/"
	export CO_LIBS="${GOPATH}/deps/libco/"
	PKG_CONFIG_PATH="${GOPATH}/deps/sqlite/" econf --libdir="${EPREFIX}/usr/$(get_libdir)/lxd"
}

src_compile() {
	export GOPATH="${S}/_dist"

	cd "${GOPATH}/deps/sqlite" || die "Can't cd to sqlite dir"
	emake

	cd "${GOPATH}/deps/raft" || die "Can't cd to raft dir"
	emake

	cd "${GOPATH}/deps/libco" || die "Can't cd to libco dir"
	emake

	cd "${GOPATH}/deps/dqlite" || die "Can't cd to dqlite dir"
	emake CFLAGS="${CFLAGS} -I${GOPATH}/deps/sqlite -I${GOPATH}/deps/raft/include" \
	LDFLAGS="${LDFLAGS} -L${GOPATH}/deps/sqlite -L${GOPATH}/deps/raft"

	# We don't use the Makefile here because it builds targets with the
	# assumption that `pwd` is in a deep gopath namespace, which we're not.
	# It's simpler to manually call "cros_go install" than patching the Makefile.
	cd "${S}"
	cros_go install -v -x ${EGO_PN}/lxc || die "Failed to build the client"

	if use daemon; then

		# LXD depends on a patched, bundled sqlite with replication
		# capabilities.
		export CGO_CFLAGS="-I${GOPATH}/deps/sqlite/ -I${GOPATH}/deps/dqlite/include/ -I${GOPATH}/deps/raft/include/ -I${GOPATH}/deps/libco/"
		export CGO_LDFLAGS="-L${GOPATH}/deps/sqlite/.libs/ -L${GOPATH}/deps/dqlite/.libs/ -L${GOPATH}/deps/raft/.libs -L${GOPATH}/deps/libco/ -Wl,-rpath,${EPREFIX}/usr/$(get_libdir)/lxd"
		export LD_LIBRARY_PATH="${GOPATH}/deps/sqlite/.libs/:${GOPATH}/deps/dqlite/.libs/:${GOPATH}/deps/raft/.libs:${GOPATH}/deps/libco/"

		cros_go install -v -x -tags libsqlite3 ${EGO_PN}/lxd || die "Failed to build the daemon"
	fi

	if use tools; then
		cros_go install -v -x ${EGO_PN}/fuidshift || die "Failed to build fuidshift"
		cros_go install -v -x ${EGO_PN}/lxc-to-lxd || die "Failed to build lxc-to-lxd"
		cros_go install -v -x ${EGO_PN}/lxd-benchmark || die "Failed to build lxd-benchmark"
		cros_go install -v -x ${EGO_PN}/lxd-p2c || die "Failed to build lxd-p2c"
	fi

	use nls && emake build-mo
}

src_test() {
	if use daemon; then
		export GOPATH="${S}/_dist"
		# This is mostly a copy/paste from the Makefile's "check" rule, but
		# patching the Makefile to work in a non "fully-qualified" go namespace
		# was more complicated than this modest copy/paste.
		# Also: sorry, for now a network connection is needed to run tests.
		# Will properly bundle test dependencies later.
		cros_go get -v -x github.com/rogpeppe/godeps
		cros_go get -v -x github.com/remyoudompheng/go-misc/deadcode
		cros_go get -v -x github.com/golang/lint/golint
		cros_go test -v ${EGO_PN}/lxd
	else
		einfo "No tests to run for client-only builds"
	fi
}

src_install() {
	cros-go_src_install

	local bindir="_dist/bin"
	if [[ ${ARCH} != "amd64" ]]; then
		bindir="${bindir}/linux_${ARCH}"
	fi
	dobin ${bindir}/lxc
	if use daemon; then

		export GOPATH="${S}/_dist"
		cd "${GOPATH}/deps/sqlite" || die "Can't cd to sqlite dir"
		emake DESTDIR="${D}" install

		cd "${GOPATH}/deps/raft" || die "Can't cd to raft dir"
		emake DESTDIR="${D}" install

		cd "${GOPATH}/deps/libco" || die "Can't cd to libco dir"
		dolib.so libco.so.0.1.0 || die "Can't install libco.so"

		cd "${GOPATH}/deps/dqlite" || die "Can't cd to dqlite dir"
		emake DESTDIR="${D}" install

		# Must only install libs
		rm "${D}/usr/bin/sqlite3" || die "Can't remove custom sqlite3 binary"
		rm -r "${D}/usr/include" || die "Can't remove include directory"

		cd "${S}" || die "Can't cd to \${S}"
		dosbin ${bindir}/lxd
	fi

	if use tools; then
		dobin ${bindir}/fuidshift
		dobin ${bindir}/lxc-to-lxd
		dobin ${bindir}/lxd-benchmark
		dobin ${bindir}/lxd-p2c
	fi

	if use nls; then
		domo po/*.mo
	fi

	# These C header files are dependencies of lxd/shared/idmap which don't
	# get installed by the usual golang tools.
	insinto "/usr/lib/gopath/src/github.com/lxc/lxd/lxd/"
	doins -r "${S}/_dist/src/github.com/lxc/lxd/lxd/include"

	newbashcomp _dist/src/${EGO_PN}/scripts/bash/lxd-client lxc

	dodoc AUTHORS _dist/src/${EGO_PN}/doc/*
}

pkg_postinst() {
	cros-go_pkg_postinst

	elog
	elog "Consult https://wiki.gentoo.org/wiki/LXD for more information,"
	elog "including a Quick Start."

	# The messaging below only applies to daemon installs
	use daemon || return 0

	# The control socket will be owned by (and writeable by) this group.
	enewgroup lxd

	# Ubuntu also defines an lxd user but it appears unused (the daemon
	# must run as root)

	elog
	elog "Though not strictly required, some features are enabled at run-time"
	elog "when the relevant helper programs are detected:"
	elog "- sys-apps/apparmor"
	elog "- sys-fs/btrfs-progs"
	elog "- sys-fs/lvm2"
	elog "- sys-fs/zfs"
	elog "- sys-process/criu"
	elog
	elog "Since these features can't be disabled at build-time they are"
	elog "not USE-conditional."
	elog
	elog "Be sure to add your local user to the lxd group."
	elog
	elog "Networks with bridge.mode=fan are unsupported due to requiring"
	elog "a patched kernel and iproute2."
}

# TODO:
# - man page, I don't see cobra generating it
# - maybe implement LXD_CLUSTER_UPDATE per
#     https://discuss.linuxcontainers.org/t/lxd-3-5-has-been-released/2656
#     EM I'm not convinced it's a good design.
