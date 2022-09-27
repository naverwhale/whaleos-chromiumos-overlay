# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="A task scheduler backed by a work-stealing thread pool"
HOMEPAGE="https://tokio.rs/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="MIT"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	=dev-rust/crossbeam-deque-0.7*:=
	=dev-rust/crossbeam-queue-0.1*:=
	=dev-rust/crossbeam-utils-0.6*:=
	=dev-rust/futures-0.1*:=
	=dev-rust/log-0.4*:=
	=dev-rust/num_cpus-1*:=
	=dev-rust/rand-0.6*:=
	=dev-rust/slab-0.4*:=
	=dev-rust/tokio-executor-0.1*:=
	=dev-rust/env_logger-0.5*:=
	=dev-rust/futures-cpupool-0.1*:=
	=dev-rust/threadpool-1*:=
"
