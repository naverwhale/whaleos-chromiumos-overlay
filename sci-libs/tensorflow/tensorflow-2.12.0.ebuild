# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_OPTIONAL=1
PYTHON_COMPAT=( python3_{6,7,8} )
DISTUTILS_USE_SETUPTOOLS=rdepend
MY_PV=${PV/_rc/-rc}
MY_P=${PN}-${MY_PV}

# shellcheck disable=SC2034 # Used by bazel.eclass.
BAZEL_BINARY="bazel-5"

# s/bazel/cros-bazel/ instead of bazel to fix downloading dependencies.
# s/prefix// because ChromeOS doesn't need it.
inherit cros-bazel cros-sanitizers distutils-r1 flag-o-matic toolchain-funcs

DESCRIPTION="Computation framework using data flow graphs for scalable machine learning"
HOMEPAGE="https://www.tensorflow.org/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="mpi +python xla xnnpack tflite_opencl_profiling ubsan nnapi_custom_ops"

# distfiles that bazel uses for the workspace, will be copied to basel-distdir
bazel_external_uris="
	https://github.com/bazelbuild/apple_support/releases/download/1.1.0/apple_support.1.1.0.tar.gz
	https://github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz
	https://github.com/bazelbuild/bazel-toolchains/archive/8c717f8258cd5f6c7a45b97d974292755852b658.tar.gz -> bazel-toolchains-8c717f8258cd5f6c7a45b97d974292755852b658.tar.gz
	https://github.com/bazelbuild/platforms/releases/download/0.0.6/platforms-0.0.6.tar.gz -> bazelbuild-platforms-0.0.6.tar.gz
	https://github.com/bazelbuild/rules_android/archive/v0.1.1.zip -> bazelbuild-rules_android-v0.1.1.zip
	https://github.com/bazelbuild/rules_apple/releases/download/1.0.1/rules_apple.1.0.1.tar.gz
	https://github.com/bazelbuild/rules_cc/archive/081771d4a0e9d7d3aa0eed2ef389fa4700dfb23e.tar.gz -> bazelbuild-rules_cc-081771d4a0e9d7d3aa0eed2ef389fa4700dfb23e.tar.gz
	https://github.com/bazelbuild/rules_closure/archive/308b05b2419edb5c8ee0471b67a40403df940149.tar.gz -> bazelbuild-rules_closure-308b05b2419edb5c8ee0471b67a40403df940149.tar.gz
	https://github.com/bazelbuild/rules_docker/releases/download/v0.10.0/rules_docker-v0.10.0.tar.gz -> bazelbuild-rules_docker-v0.10.0.tar.gz
	https://github.com/bazelbuild/rules_java/archive/7cf3cefd652008d0a64a419c34c13bdca6c8f178.zip -> bazelbuild-rules_java-7cf3cefd652008d0a64a419c34c13bdca6c8f178.zip
	https://github.com/bazelbuild/rules_jvm_external/archive/4.3.zip -> bazelbuild-rules_jvm_external-4.3.zip
	https://github.com/bazelbuild/rules_pkg/releases/download/0.7.1/rules_pkg-0.7.1.tar.gz -> bazelbuild-rules_pkg-0.7.1.tar.gz
	https://github.com/bazelbuild/rules_proto/archive/11bf7c25e666dd7ddacbcd4d4c4a9de7a25175f8.tar.gz -> bazelbuild-rules_proto-11bf7c25e666dd7ddacbcd4d4c4a9de7a25175f8.tar.gz
	https://github.com/bazelbuild/rules_python/releases/download/0.0.1/rules_python-0.0.1.tar.gz -> bazelbuild-rules_python-0.0.1.tar.gz
	https://github.com/bazelbuild/rules_swift/releases/download/1.0.0/rules_swift.1.0.0.tar.gz -> bazelbuild-rules_swift.1.0.0.tar.gz
	https://github.com/google/farmhash/archive/0d859a811870d10f53a594927d0d0b97573ad06d.tar.gz -> farmhash-0d859a811870d10f53a594927d0d0b97573ad06d.tar.gz
	https://github.com/google/gemmlowp/archive/e844ffd17118c1e17d94e1ba4354c075a4577b88.zip -> gemmlowp-e844ffd17118c1e17d94e1ba4354c075a4577b88.zip
	https://github.com/google/highwayhash/archive/c13d28517a4db259d738ea4886b1f00352a3cc33.tar.gz -> highwayhash-c13d28517a4db259d738ea4886b1f00352a3cc33.tar.gz
	https://github.com/google/ruy/archive/3286a34cc8de6149ac6844107dfdffac91531e72.zip -> ruy-3286a34cc8de6149ac6844107dfdffac91531e72.zip
	https://github.com/google/XNNPACK/archive/659147817805d17c7be2d60bd7bbca7e780f9c82.zip -> XNNPACK-659147817805d17c7be2d60bd7bbca7e780f9c82.zip
	https://github.com/googleapis/googleapis/archive/6b3fdcea8bc5398be4e7e9930c693f0ea09316a0.tar.gz -> 6b3fdcea8bc5398be4e7e9930c693f0ea09316a0.tar.gz
	https://github.com/intel/ARM_NEON_2_x86_SSE/archive/a15b489e1222b2087007546b4912e21293ea86ff.tar.gz -> ARM_NEON_2_x86_SSE-a15b489e1222b2087007546b4912e21293ea86ff.tar.gz
	https://github.com/KhronosGroup/OpenCL-Headers/archive/dcd5bede6859d26833cd85f0d6bbcee7382dc9b3.tar.gz -> dcd5bede6859d26833cd85f0d6bbcee7382dc9b3.tar.gz
	https://github.com/KhronosGroup/Vulkan-Headers/archive/32c07c0c5334aea069e518206d75e002ccd85389.tar.gz -> 32c07c0c5334aea069e518206d75e002ccd85389.tar.gz
	https://github.com/Maratyszcza/FP16/archive/4dfe081cf6bcd15db339cf2680b9281b8451eeb3.zip -> FP16-4dfe081cf6bcd15db339cf2680b9281b8451eeb3.zip
	https://github.com/Maratyszcza/FXdiv/archive/63058eff77e11aa15bf531df5dd34395ec3017c8.zip -> FXdiv-63058eff77e11aa15bf531df5dd34395ec3017c8.zip
	https://github.com/Maratyszcza/pthreadpool/archive/b8374f80e42010941bda6c85b0e3f1a1bd77a1e0.zip -> pthreadpool-b8374f80e42010941bda6c85b0e3f1a1bd77a1e0.zip
	https://github.com/petewarden/OouraFFT/archive/v1.0.tar.gz -> OouraFFT-v1.0.tar.gz
	https://github.com/pytorch/cpuinfo/archive/3dc310302210c1891ffcfb12ae67b11a3ad3a150.zip -> pytorch-cpuinfo-3dc310302210c1891ffcfb12ae67b11a3ad3a150.zip
	https://github.com/tensorflow/runtime/archive/91d765cad5599f9710973d3e34d4dc22583e2e79.tar.gz -> tensorflow-runtime-91d765cad5599f9710973d3e34d4dc22583e2e79.tar.gz
	https://gitlab.com/libeigen/eigen/-/archive/3460f3558e7b469efb8a225894e21929c8c77629/eigen-3460f3558e7b469efb8a225894e21929c8c77629.tar.gz
	https://storage.googleapis.com/mirror.tensorflow.org/storage.cloud.google.com/download.tensorflow.org/tflite/hexagon_nn_headers_v1.20.0.9.tgz -> hexagon_nn_headers_v1.20.0.9.tgz
"

SRC_URI="https://github.com/${PN}/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz
		https://dev.gentoo.org/~perfinion/patches/tensorflow-patches-${PV}.tar.bz2
		${bazel_external_uris}"

RDEPEND="
	x11-drivers/opengles-headers:=
	virtual/opengles:=
	dev-cpp/abseil-cpp:=
	>=dev-libs/flatbuffers-1.12.0:=
	dev-libs/openssl:0=
	>=dev-libs/nsync-1.25.0
	>=dev-libs/protobuf-3.8.0:=
	>=dev-libs/re2-0.2019.06.01
	media-libs/giflib
	media-libs/libjpeg-turbo
	media-libs/libpng:0
	net-misc/curl
	sys-libs/zlib
	mpi? ( virtual/mpi )
	python? (
		${PYTHON_DEPS}
		dev-python/absl-py[${PYTHON_USEDEP}]
		>=dev-python/astor-0.7.1[${PYTHON_USEDEP}]
		dev-python/astunparse[${PYTHON_USEDEP}]
		>=dev-python/gast-0.3.3[${PYTHON_USEDEP}]
		dev-python/h5py[${PYTHON_USEDEP}]
		>=dev-python/numpy-1.19[${PYTHON_USEDEP}]
		>=dev-python/google-pasta-0.1.8[${PYTHON_USEDEP}]
		dev-python/opt-einsum[${PYTHON_USEDEP}]
		>=dev-python/protobuf-python-3.8.0[${PYTHON_USEDEP}]
		dev-python/pybind11[${PYTHON_USEDEP}]
		dev-python/six[${PYTHON_USEDEP}]
		dev-python/termcolor[${PYTHON_USEDEP}]
		>=dev-python/grpcio-1.28[${PYTHON_USEDEP}]
		>=dev-python/wrapt-1.11.1[${PYTHON_USEDEP}]
		>=net-libs/google-cloud-cpp-0.10.0
		>=sci-libs/keras-applications-1.0.8[${PYTHON_USEDEP}]
		>=sci-libs/keras-preprocessing-1.1.0[${PYTHON_USEDEP}]
		>=sci-visualization/tensorboard-2.3.0[${PYTHON_USEDEP}]
		dev-python/dill[${PYTHON_USEDEP}]
		dev-python/tblib[${PYTHON_USEDEP}]
	)"
DEPEND="${RDEPEND}
	python? (
		dev-python/setuptools
	)"
PDEPEND="python? (
		>=sci-libs/tensorflow-estimator-2.3.0[${PYTHON_USEDEP}]
	)"
BDEPEND="
	app-arch/unzip
	>=dev-libs/protobuf-3.8.0
	dev-java/java-config
	dev-lang/perl
	dev-libs/flatbuffers
	=dev-util/bazel-5*
	${PYTHON_DEPS}
	python? (
		dev-python/cython
		>=dev-python/grpcio-tools-1.28
	)
	>=dev-python/numpy-1.19[${PYTHON_USEDEP}]
	sys-apps/which
	sys-devel/gettext
"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

PATCHES=(
	"${FILESDIR}/${P}-0001-workspace.patch"
	"${FILESDIR}/${P}-0002-ashmem-create.patch"
	"${FILESDIR}/${P}-0003-nnapi-delegates.patch"
	"${FILESDIR}/${P}-0005-gpu.patch"
	"${FILESDIR}/${P}-0006-nnapi-loading-errors.patch"
	"${FILESDIR}/${P}-0008-remove-llvm-repo.patch"
	"${FILESDIR}/${P}-0011-Convolution2DTransposeBias.patch"
)

S="${WORKDIR}/${MY_P}"

DOCS=( AUTHORS CONTRIBUTING.md ISSUE_TEMPLATE.md README.md RELEASE.md )

# Echos the CPU string that TensorFlow uses to refer to the given architecture.
get-cpu-str() {
	local arch
	arch="$(tc-arch "${1}")"

	case "${arch}" in
	amd64) echo "k8";;
	arm) echo "arm";;
	arm64) echo "aarch64";;
	*) die "Unsupported architecture '${arch}'."
	esac
}

pkg_setup() {
	local num_pythons_enabled
	num_pythons_enabled=0
	count_impls(){
		num_pythons_enabled=$((num_pythons_enabled + 1))
	}
	use python && python_foreach_impl count_impls
}

src_unpack() {
	# Only unpack the main distfile
	unpack "${P}.tar.gz"
	unpack tensorflow-patches-${PV}.tar.bz2
	bazel_load_distfiles "${bazel_external_uris}"
}

src_prepare() {
	if use nnapi_custom_ops; then
		PATCHES+=("${FILESDIR}/${P}-0010-Convolution2DTransposeBias-nnapi.patch")
	fi

	eapply "${WORKDIR}"/patches/*.patch

	export JAVA_HOME=$(ROOT="${BROOT}" java-config --jdk-home)

	# Relax version checks in setup.py
	sed -i "/^    '/s/==/>=/g" tensorflow/tools/pip_package/setup.py || die

	# -lnativewindow is for Android
	sed -i 's/\["-lnativewindow"\]/[]/g' tensorflow/lite/delegates/gpu/build_defs.bzl || die

	append-lfs-flags
	sanitizers-setup-env
	bazel_setup_bazelrc
	bazel_setup_crosstool "$(get-cpu-str "${CBUILD}")" "$(get-cpu-str "${CHOST}")"

	default
	use python && python_copy_sources
}

src_configure() {
	export JAVA_HOME=$(ROOT="${BROOT}" java-config --jdk-home)

	do_configure() {
		export CC_OPT_FLAGS=" "
		export TF_ENABLE_XLA=$(usex xla 1 0)
		export TF_NEED_OPENCL_SYCL=0
		export TF_NEED_OPENCL=0
		export TF_NEED_COMPUTECPP=0
		export TF_NEED_ROCM=0
		export TF_NEED_MPI=$(usex mpi 1 0)
		export TF_SET_ANDROID_WORKSPACE=0

		if use python; then
			export PYTHON_BIN_PATH="${PYTHON}"
			export PYTHON_LIB_PATH="$(python_get_sitedir)"
		else
			python_setup
			export PYTHON_BIN_PATH="${PYTHON}"
			# PYTHON_LIB_PATH is inferred automatically
		fi

		export TF_NEED_CUDA=0
		export TF_DOWNLOAD_CLANG=0
		export TF_CUDA_CLANG=0
		export TF_NEED_TENSORRT=0

		local SYSLIBS=(
			absl_py
			astor_archive
			astunparse_archive
			boringssl
			com_github_googlecloudplatform_google_cloud_cpp
			com_github_grpc_grpc
			com_google_absl
			com_google_protobuf
			com_googlesource_code_re2
			curl
			cython
			dill_archive
			double_conversion
			flatbuffers
			functools32_archive
			gast_archive
			gif
			hwloc
			icu
			jsoncpp_git
			libjpeg_turbo
			lmdb
			nasm
			nsync
			opt_einsum_archive
			org_sqlite
			pasta
			png
			pybind11
			six_archive
			snappy
			tblib_archive
			termcolor_archive
			typing_extensions_archive
			wrapt
			zlib
		)

		export TF_SYSTEM_LIBS="${SYSLIBS[*]}"
		export TF_IGNORE_MAX_BAZEL_VERSION=1

		# This is not autoconf
		./configure || die

		bazel_setup_system_protobuf
		cros-bazel-add-rc 'build --config=noaws --config=nohdfs'
		cros-bazel-add-rc 'build --define tensorflow_mkldnn_contraction_kernel=0'
		cros-bazel-add-copt '-DEGL_NO_X11'

		# Detects whether the target CPU supports SSE4.2.
		# Note: the check requires no double quote on CFLAGS and CPPFLAGS.
		# shellcheck disable=SC2086
		if ! tc-cpp-is-true "defined(__SSE4_2__)" ${CFLAGS} ${CPPFLAGS}; then
			cros-bazel-add-copt '-mno-sse4.2'
		fi

		# The ruy library is faster than the default libeigen on arm, but
		# MUCH slower on amd64. See b/178593695 for more discussion.
		case "${ARCH}" in
			arm | arm64) cros-bazel-add-rc 'build --define=tflite_with_ruy=true' ;;
		esac
	}
	if use python; then
		python_foreach_impl run_in_build_dir do_configure
	else
		do_configure
	fi
}

src_compile() {
	export JAVA_HOME=$(ROOT="${BROOT}" java-config --jdk-home)

	if use python; then
		python_setup
		BUILD_DIR="${S}-${EPYTHON/./_}"
		cd "${BUILD_DIR}" || die
	fi

	local bazel_args=()
	bazel_args+=("tensorflow/lite:libtensorflowlite.so")
	bazel_args+=("//tensorflow/lite/kernels/internal:install_nnapi_extra_headers")
	if ! use ubsan; then
		bazel_args+=("//tensorflow/lite/tools/evaluation/tasks/inference_diff:run_eval")
		bazel_args+=("//tensorflow/lite/tools/evaluation/tasks/coco_object_detection:run_eval")
		bazel_args+=("//tensorflow/lite/tools/benchmark:benchmark_model")
	fi

	if use tflite_opencl_profiling; then
		bazel_args+=("//tensorflow/lite/delegates/gpu/cl/testing:performance_profiling")
	fi

	local build_flags=(
		--cxxopt=-std=gnu++20
		--define tflite_keep_symbols=true
	)

	# fail early if any deps are missing
	ebazel build "${build_flags[@]}" -k --nobuild "${bazel_args[@]}"
	# build if deps are present
	ebazel build "${build_flags[@]}" "${bazel_args[@]}"

	do_compile() {
		ebazel build "${build_flags[@]}" //tensorflow/tools/pip_package:build_pip_package
	}
	BUILD_DIR="${S}"
	cd "${BUILD_DIR}" || die
	use python && python_foreach_impl run_in_build_dir do_compile
	ebazel shutdown

	einfo "Generate pkg-config file"
	chmod +x ${PN}/lite/generate-pc.sh
	${PN}/lite/generate-pc.sh --prefix="${EPREFIX}"/usr --libdir="$(get_libdir)" --version=${MY_PV} || die
}

src_install() {
	local i
	export JAVA_HOME=$(ROOT="${BROOT}" java-config --jdk-home)

	einfo "Installing TF lite headers"

	local HEADERS_TMP
	HEADERS_TMP="${WORKDIR}/headers_tmp"
	mkdir -p "${HEADERS_TMP}"

	# From tensorflow/lite/lib_package/create_ios_frameworks.sh
	find ${PN}/lite -name "*.h" \
		-not -path "${PN}/lite/tools/*" \
		-not -path "${PN}/lite/examples/*" \
		-not -path "${PN}/lite/gen/*" \
		-not -path "${PN}/lite/toco/*" \
		-not -path "${PN}/lite/java/*" |
	while read -r i; do
		mkdir -p "${HEADERS_TMP}/${i%/*}"
		cp "${i}" "${HEADERS_TMP}/${i%/*}"
	done

	insinto "/usr/include/${PN}"
	doins -r "${HEADERS_TMP}/tensorflow"

	einfo "Installing selected TF core headers"
	local selected=( lib/bfloat16/bfloat16.h platform/byte_order.h platform/macros.h platform/bfloat16.h )
	for i in "${selected[@]}"; do
		insinto "/usr/include/${PN}/${PN}/core/${i%/*}"
		doins "${PN}/core/${i}"
	done

	einfo "Installing NNAPI headers"
	insinto /usr/include/${PN}/nnapi/
	doins -r bazel-bin/tensorflow/lite/kernels/internal/include

	einfo "Installing ruy headers"
	insinto /usr/include/${PN}/ruy/
	doins -r "../tensorflow-${PV}-bazel-base/external/ruy/ruy"/*

	einfo "Installing fp16 headers"
	insinto /usr/include/${PN}/
	doins -r "../tensorflow-${PV}-bazel-base/external/FP16/include"/*

	einfo "Installing TF lite libraries"
	dolib.so bazel-bin/tensorflow/lite/lib${PN}lite.so

	if ! use ubsan; then
		into /usr/local
		einfo "Install benchmark_model tool to /usr/local/bin"
		dobin bazel-bin/tensorflow/lite/tools/benchmark/benchmark_model
		einfo "Install inference diff evaluation tool"
		newbin bazel-bin/tensorflow/lite/tools/evaluation/tasks/inference_diff/run_eval inference_diff_eval
		einfo "Install object detection evaluation tool"
		newbin bazel-bin/tensorflow/lite/tools/evaluation/tasks/coco_object_detection/run_eval object_detection_eval
	fi

	if use tflite_opencl_profiling; then
		into /usr/local/
		einfo "Install performance_profiling tool"
		dobin bazel-bin/tensorflow/lite/delegates/gpu/cl/testing/performance_profiling
	fi

	if use xnnpack; then
		einfo "Installing XNNPACK headers and libs"
		local bindir="../tensorflow-${PV}-bazel-base/execroot/org_tensorflow/bazel-out/$(get-cpu-str "${CHOST}")-opt/bin/external/"
		insinto /usr/include/${PN}/xnnpack/
		doins "../tensorflow-${PV}-bazel-base/external/XNNPACK/include/xnnpack.h"
		doins "../tensorflow-${PV}-bazel-base/external/pthreadpool/include/pthreadpool.h"
		dolib.a "${bindir}/clog/libclog.a"
		dolib.a "${bindir}/cpuinfo/libcpuinfo_impl.pic.a"
		dolib.a "${bindir}/pthreadpool/libpthreadpool.a"
		# The lib names vary wildly between amd64 and arm, so
		# easier just to scan for them rather than explicitly
		# listing them and switching on ${ARCH}.
		find "${bindir}/XNNPACK/" -name "*.a" |
		while read -r i; do
			dolib.a "${i}"
		done
	fi

	einfo "Installing pkg-config file"
	insinto /usr/"$(get_libdir)"/pkgconfig
	doins ${PN}lite.pc

	einstalldocs
}
