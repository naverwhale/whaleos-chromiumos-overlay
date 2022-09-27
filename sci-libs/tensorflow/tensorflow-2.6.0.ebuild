# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_OPTIONAL=1
PYTHON_COMPAT=( python3_{6,7,8} )
DISTUTILS_USE_SETUPTOOLS=rdepend
MY_PV=${PV/_rc/-rc}
MY_P=${PN}-${MY_PV}

# s/bazel/cros-bazel/ instead of bazel to fix downloading dependencies.
# s/prefix// because ChromeOS doesn't need it.
inherit cros-bazel check-reqs cuda distutils-r1 flag-o-matic toolchain-funcs

DESCRIPTION="Computation framework using data flow graphs for scalable machine learning"
HOMEPAGE="https://www.tensorflow.org/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
# ChromeOS uses 'minimal' to compile only TensorFlow Lite, compilation without 'minimal' is not supported.
IUSE="cuda mpi +python xla minimal label_image benchmark_model xnnpack"

# distfiles that bazel uses for the workspace, will be copied to basel-distdir
bazel_external_uris="
	https://github.com/bazelbuild/platforms/releases/download/0.0.2/platforms-0.0.2.tar.gz -> bazelbuild-platforms-0.0.2.tar.gz
	https://github.com/bazelbuild/apple_support/archive/501b4afb27745c4813a88ffa28acd901408014e4.tar.gz -> bazelbuild-apple_support-501b4afb27745c4813a88ffa28acd901408014e4.tar.gz
	https://github.com/bazelbuild/bazel-toolchains/archive/92dd8a7a518a2fb7ba992d47c8b38299fe0be825.tar.gz -> bazel-toolchains-92dd8a7a518a2fb7ba992d47c8b38299fe0be825.tar.gz
	https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.3/bazel-skylib-1.0.3.tar.gz -> bazel-skylib-1.0.3.tar.gz
	https://github.com/bazelbuild/rules_android/archive/v0.1.1.zip -> bazelbuild-rules_android-v0.1.1.zip
	https://github.com/bazelbuild/rules_apple/archive/5131f3d46794bf227d296c82f30c2499c9de3c5b.tar.gz -> bazelbuild-rules_apple-5131f3d46794bf227d296c82f30c2499c9de3c5b.tar.gz
	https://github.com/bazelbuild/rules_cc/archive/40548a2974f1aea06215272d9c2b47a14a24e556.tar.gz -> bazelbuild-rules_cc-40548a2974f1aea06215272d9c2b47a14a24e556.tar.gz
	https://github.com/bazelbuild/rules_closure/archive/308b05b2419edb5c8ee0471b67a40403df940149.tar.gz -> bazelbuild-rules_closure-308b05b2419edb5c8ee0471b67a40403df940149.tar.gz
	https://github.com/bazelbuild/rules_java/archive/7cf3cefd652008d0a64a419c34c13bdca6c8f178.zip -> bazelbuild-rules_java-7cf3cefd652008d0a64a419c34c13bdca6c8f178.zip
	https://github.com/bazelbuild/rules_swift/archive/3eeeb53cebda55b349d64c9fc144e18c5f7c0eb8.tar.gz -> bazelbuild-rules_swift-3eeeb53cebda55b349d64c9fc144e18c5f7c0eb8.tar.gz
	https://github.com/google/farmhash/archive/816a4ae622e964763ca0862d9dbd19324a1eaf45.tar.gz -> farmhash-816a4ae622e964763ca0862d9dbd19324a1eaf45.tar.gz
	https://github.com/google/gemmlowp/archive/fda83bdc38b118cc6b56753bd540caa49e570745.zip -> gemmlowp-fda83bdc38b118cc6b56753bd540caa49e570745.zip
	https://github.com/google/ruy/archive/e6c1b8dc8a8b00ee74e7268aac8b18d7260ab1ce.zip -> ruy-e6c1b8dc8a8b00ee74e7268aac8b18d7260ab1ce.zip
	https://github.com/intel/ARM_NEON_2_x86_SSE/archive/1200fe90bb174a6224a525ee60148671a786a71f.tar.gz -> ARM_NEON_2_x86_SSE-1200fe90bb174a6224a525ee60148671a786a71f.tar.gz	https://github.com/googleapis/googleapis/archive/541b1ded4abadcc38e8178680b0677f65594ea6f.zip -> googleapis-541b1ded4abadcc38e8178680b0677f65594ea6f.zip
	https://github.com/petewarden/OouraFFT/archive/v1.0.tar.gz -> OouraFFT-v1.0.tar.gz
	https://github.com/pytorch/cpuinfo/archive/5916273f79a21551890fd3d56fc5375a78d1598d.zip -> pytorch-cpuinfo-5916273f79a21551890fd3d56fc5375a78d1598d.zip
	https://github.com/pytorch/cpuinfo/archive/d5e37adf1406cf899d7d9ec1d317c47506ccb970.tar.gz -> pytorch-cpuinfo-d5e37adf1406cf899d7d9ec1d317c47506ccb970.tar.gz
	https://github.com/Maratyszcza/FP16/archive/4dfe081cf6bcd15db339cf2680b9281b8451eeb3.zip -> FP16-4dfe081cf6bcd15db339cf2680b9281b8451eeb3.zip
	https://github.com/Maratyszcza/FXdiv/archive/63058eff77e11aa15bf531df5dd34395ec3017c8.zip -> FXdiv-63058eff77e11aa15bf531df5dd34395ec3017c8.zip
	https://github.com/Maratyszcza/pthreadpool/archive/b8374f80e42010941bda6c85b0e3f1a1bd77a1e0.zip -> pthreadpool-b8374f80e42010941bda6c85b0e3f1a1bd77a1e0.zip
	https://github.com/tensorflow/toolchains/archive/v1.1.21.tar.gz -> tensorflow_toolchains_v1.1.21.tar.gz
	https://github.com/tensorflow/runtime/archive/b570a1921c9e55ac53c8972bd2bfd37cd0eb510d.tar.gz -> tf_runtime-b570a1921c9e55ac53c8972bd2bfd37cd0eb510d.tar.gz
	https://gitlab.com/libeigen/eigen/-/archive/12e8d57108c50d8a63605c6eb0144c838c128337/eigen-12e8d57108c50d8a63605c6eb0144c838c128337.tar.gz -> eigen-12e8d57108c50d8a63605c6eb0144c838c128337.tar.gz
	https://github.com/KhronosGroup/OpenCL-Headers/archive/0d5f18c6e7196863bc1557a693f1509adfcee056.tar.gz -> OpenCL-Headers-0d5f18c6e7196863bc1557a693f1509adfcee056.tar.gz
	https://github.com/KhronosGroup/Vulkan-Headers/archive/ec2db85225ab410bc6829251bef6c578aaed5868.tar.gz -> Vulkan-Headers-ec2db85225ab410bc6829251bef6c578aaed5868.tar.gz
	https://github.com/abseil/abseil-cpp/archive/997aaf3a28308eba1b9156aa35ab7bca9688e9f6.tar.gz -> abseil-cpp-997aaf3a28308eba1b9156aa35ab7bca9688e9f6.tar.gz
	https://github.com/google/XNNPACK/archive/476eb84d6a8e6f8249d5584d30759c6fbdbf791d.zip -> xnnpack-476eb84d6a8e6f8249d5584d30759c6fbdbf791d.zip
"

SRC_URI="
	https://github.com/${PN}/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz
	${bazel_external_uris}
	"

RDEPEND="
	x11-drivers/opengles-headers:=
	virtual/opengles:=
	!minimal? (
		app-arch/snappy
		dev-db/lmdb
		dev-db/sqlite
		dev-libs/double-conversion
		dev-libs/icu
		>=dev-libs/jsoncpp-1.9.2
	)
	>=dev-libs/flatbuffers-1.12.0:=
	dev-libs/libpcre
	!minimal? (
		dev-libs/nsync
	)
	dev-libs/openssl:0=
	>=dev-libs/protobuf-3.8.0:=
	>=dev-libs/re2-0.2019.06.01
	!minimal? (
		media-libs/giflib
	)
	media-libs/libjpeg-turbo
	media-libs/libpng:0
	!minimal? (
		>=net-libs/grpc-1.28
	)
	net-misc/curl
	sys-libs/zlib
	!minimal? (
		>=sys-apps/hwloc-2
	)
	cuda? (
		|| (
			( =dev-util/nvidia-cuda-toolkit-10.2*[profiler] =dev-libs/cudnn-7* )
			( =dev-util/nvidia-cuda-toolkit-10.1*[profiler] =dev-libs/cudnn-7* )
			( =dev-util/nvidia-cuda-toolkit-10.0*[profiler] =dev-libs/cudnn-7.4* )
			( =dev-util/nvidia-cuda-toolkit-9.2*[profiler] =dev-libs/cudnn-7.1* )
			( =dev-util/nvidia-cuda-toolkit-9.1*[profiler] =dev-libs/cudnn-7.0* )
		)
	)
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
		dev-python/mock
		dev-python/setuptools
	)"
PDEPEND="python? (
		>=sci-libs/tensorflow-estimator-2.3.0[${PYTHON_USEDEP}]
	)"
BDEPEND="
	app-arch/unzip
	>=dev-libs/protobuf-3.8.0
	dev-java/java-config
	dev-lang/swig
	=dev-util/bazel-3*
	cuda? (
		>=dev-util/nvidia-cuda-toolkit-9.1[profiler]
	)
	!python? ( dev-lang/python )
	python? (
		dev-python/cython
		dev-python/mock
		>=dev-python/grpcio-tools-1.28
	)"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

PATCHES=(
	"${FILESDIR}/tensorflow-2.6.0-0001-workspace.patch"
	"${FILESDIR}/tensorflow-2.6.0-0002-ashmem-create.patch"
	"${FILESDIR}/tensorflow-2.6.0-0003-nnapi-delegates.patch"
	"${FILESDIR}/tensorflow-2.6.0-0004-cpuinfo-arm-fix.patch"
	"${FILESDIR}/tensorflow-2.6.0-0005-gpu.patch"
	"${FILESDIR}/tensorflow-2.6.0-0006-nnapi-loading-errors.patch"
)

S="${WORKDIR}/${MY_P}"

DOCS=( AUTHORS CONTRIBUTING.md ISSUE_TEMPLATE.md README.md RELEASE.md )
CHECKREQS_MEMORY="5G"
CHECKREQS_DISK_BUILD="10G"

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
		num_pythons_enabled=$((${num_pythons_enabled} + 1))
	}
	use python && python_foreach_impl count_impls

	# 10G to build C/C++ libs, 5G per python impl
	CHECKREQS_DISK_BUILD="$((10 + 6 * ${num_pythons_enabled}))G"
	check-reqs_pkg_setup
}

src_unpack() {
	# Only unpack the main distfile
	unpack "${P}.tar.gz"
	bazel_load_distfiles "${bazel_external_uris}"
}

src_prepare() {
	export JAVA_HOME=$(ROOT="${BROOT}" java-config --jdk-home)

	# Relax version checks in setup.py
	sed -i "/^    '/s/==/>=/g" tensorflow/tools/pip_package/setup.py || die

	bazel_setup_bazelrc
	bazel_setup_crosstool "$(get-cpu-str "${CBUILD}")" "$(get-cpu-str "${CHOST}")"

	default
	use python && python_copy_sources

	use cuda && cuda_add_sandbox
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
			export PYTHON_BIN_PATH="$(which python)"
			export PYTHON_LIB_PATH="$(python -c 'from distutils.sysconfig import *; print(get_python_lib())')"
		fi

		export TF_NEED_CUDA=$(usex cuda 1 0)
		export TF_DOWNLOAD_CLANG=0
		export TF_CUDA_CLANG=0
		export TF_NEED_TENSORRT=0
		if use cuda; then
			export TF_CUDA_PATHS="${EPREFIX}/opt/cuda"
			export GCC_HOST_COMPILER_PATH="$(cuda_gccdir)/$(tc-getCC)"
			export TF_CUDA_VERSION="$(cuda_toolkit_version)"
			export TF_CUDNN_VERSION="$(cuda_cudnn_version)"
			einfo "Setting CUDA version: $TF_CUDA_VERSION"
			einfo "Setting CUDNN version: $TF_CUDNN_VERSION"

			if [[ *$(gcc-version)* != $(cuda-config -s) ]]; then
				ewarn "TensorFlow is being built with Nvidia CUDA support. Your default compiler"
				ewarn "version is not supported by the currently installed CUDA. TensorFlow will"
				ewarn "instead be compiled using: ${GCC_HOST_COMPILER_PATH}."
				ewarn "If the build fails with linker errors try rebuilding the relevant"
				ewarn "dependencies using the same compiler version."
			fi

			if [[ -z "$TF_CUDA_COMPUTE_CAPABILITIES" ]]; then
				ewarn "WARNING: Tensorflow is being built with its default CUDA compute capabilities: 3.5 and 7.0."
				ewarn "These may not be optimal for your GPU."
				ewarn ""
				ewarn "To configure Tensorflow with the CUDA compute capability that is optimal for your GPU,"
				ewarn "set TF_CUDA_COMPUTE_CAPABILITIES in your make.conf, and re-emerge tensorflow."
				ewarn "For example, to use CUDA capability 7.5 & 3.5, add: TF_CUDA_COMPUTE_CAPABILITIES=7.5,3.5"
				ewarn ""
				ewarn "You can look up your GPU's CUDA compute capability at https://developer.nvidia.com/cuda-gpus"
				ewarn "or by running /opt/cuda/extras/demo_suite/deviceQuery | grep 'CUDA Capability'"
			fi
		fi

		local SYSLIBS=(
			absl_py
			astor_archive
			astunparse_archive
			boringssl
			com_github_googleapis_googleapis
			com_github_googlecloudplatform_google_cloud_cpp
			com_github_grpc_grpc
			com_google_protobuf
			curl
			cython
			dill_archive
			double_conversion
			enum34_archive
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
			pcre
			png
			pybind11
			six_archive
			snappy
			swig
			tblib_archive
			termcolor_archive
			wrapt
			zlib
		)

		export TF_SYSTEM_LIBS="${SYSLIBS[@]}"
		export TF_IGNORE_MAX_BAZEL_VERSION=1

		# This is not autoconf
		./configure || die

		echo 'build --config=noaws --config=nohdfs' >> .bazelrc || die
		echo 'build --define tensorflow_mkldnn_contraction_kernel=0' >> .bazelrc || die

		# The ruy library is faster than the default libeigen on arm, but
		# MUCH slower on amd64. See b/178593695 for more discussion.
		case "${ARCH}" in
			arm | arm64) echo 'build --define=tflite_with_ruy=true' >> .bazelrc || die ;;
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
		cd "${BUILD_DIR}"
	fi

	# fail early if any deps are missing
	if ! use minimal; then
		ebazel build -k --nobuild \
			//tensorflow:libtensorflow_framework.so \
			//tensorflow:libtensorflow.so \
			//tensorflow:libtensorflow_cc.so \
			$(usex python '//tensorflow/tools/pip_package:build_pip_package' '')
	else
		ebazel build -k --nobuild \
			tensorflow/lite:libtensorflowlite.so \
			//tensorflow/lite/kernels/internal:install_nnapi_extra_headers \
			"$(usex label_image '
				//tensorflow/lite/examples/label_image:label_image' '')" \
			"$(usex benchmark_model '
				//tensorflow/lite/tools/benchmark:benchmark_model' '')" \
			"$(usex python '//tensorflow/tools/pip_package:build_pip_package' '')"
	fi

	if ! use minimal; then
		ebazel build \
			//tensorflow:libtensorflow_framework.so \
			//tensorflow:libtensorflow.so
		ebazel build //tensorflow:libtensorflow_cc.so
	else
		ebazel build --copt=-DTFLITE_SUPPORTS_GPU_DELEGATE=1 --copt=-DEGL_NO_X11 \
			//tensorflow/lite:libtensorflowlite.so \
			//tensorflow/lite/kernels/internal:install_nnapi_extra_headers \
			"$(usex label_image '
				//tensorflow/lite/examples/label_image:label_image' '')" \
			"$(usex benchmark_model '
				//tensorflow/lite/tools/benchmark:benchmark_model' '')"
	fi

	do_compile() {
		ebazel build //tensorflow/tools/pip_package:build_pip_package
	}
	BUILD_DIR="${S}"
	cd "${BUILD_DIR}"
	use python && python_foreach_impl run_in_build_dir do_compile
	ebazel shutdown
}

src_install() {
	local i j
	export JAVA_HOME=$(ROOT="${BROOT}" java-config --jdk-home)

	if ! use minimal; then
		do_install() {
			einfo "Installing ${EPYTHON} files"
			local srcdir="${T}/src-${MULTIBUILD_VARIANT}"
			mkdir -p "${srcdir}" || die
			bazel-bin/tensorflow/tools/pip_package/build_pip_package --src "${srcdir}" || die
			cd "${srcdir}" || die
			esetup.py install

			# libtensorflow_framework.so is in /usr/lib already
			rm -f "${D}/$(python_get_sitedir)"/${PN}/lib${PN}_framework.so* || die
			rm -f "${D}/$(python_get_sitedir)"/${PN}_core/lib${PN}_framework.so* || die
			python_optimize
		}

		if use python; then
			python_foreach_impl run_in_build_dir do_install

			# Symlink to python-exec scripts
			for i in "${ED}"/usr/lib/python-exec/*/*; do
				n="${i##*/}"
				[[ -e "${ED}/usr/bin/${n}" ]] || dosym ../lib/python-exec/python-exec2 "/usr/bin/${n}"
			done

			python_setup
			local BUILD_DIR="${S}-${EPYTHON/./_}"
			cd "${BUILD_DIR}" || die
		fi

		einfo "Installing headers"
		ebazel build //tensorflow:install_headers
		ebazel shutdown
		insinto /usr/include/${PN}/
		doins -r bazel-bin/tensorflow/include/*

		einfo "Installing libs"
		# Generate pkg-config file
		${PN}/c/generate-pc.sh --prefix="${EPREFIX}"/usr --libdir=$(get_libdir) --version=${MY_PV} || die
		insinto /usr/$(get_libdir)/pkgconfig
		doins ${PN}.pc ${PN}_cc.pc

		for l in libtensorflow{,_framework,_cc}.so; do
			dolib.so bazel-bin/tensorflow/${l}
			dolib.so bazel-bin/tensorflow/${l}.$(ver_cut 1)
			dolib.so bazel-bin/tensorflow/${l}.$(ver_cut 1-3)
		done
	else
		einfo "Installing TF lite headers"
		# From tensorflow/lite/lib_package/create_ios_frameworks.sh
		find ${PN}/lite -name "*.h" \
			-not -path "${PN}/lite/tools/*" \
			-not -path "${PN}/lite/examples/*" \
			-not -path "${PN}/lite/gen/*" \
			-not -path "${PN}/lite/toco/*" \
			-not -path "${PN}/lite/java/*" |
		while read -r i; do
			insinto "/usr/include/${PN}/${i%/*}"
			doins "${i}"
		done
		if use minimal; then
			einfo "Installing selected TF core headers"
			local selected=( lib/bfloat16/bfloat16.h platform/byte_order.h platform/macros.h platform/bfloat16.h )
			for i in "${selected[@]}"; do
				insinto "/usr/include/${PN}/${PN}/core/${i%/*}"
				doins "${PN}/core/${i}"
			done
		fi

		einfo "Installing NNAPI headers"
		insinto /usr/include/${PN}/nnapi/
		doins -r bazel-bin/tensorflow/lite/kernels/internal/include

		einfo "Installing ruy headers"
		insinto /usr/include/${PN}/ruy/
		doins -r "../tensorflow-${PV}-bazel-base/external/ruy/ruy"/*

		einfo "Installing TF lite libraries"
		dolib.so bazel-bin/tensorflow/lite/lib${PN}lite.so

		if use label_image; then
			einfo "Install label_image example"
			dobin bazel-bin/tensorflow/lite/examples/label_image/label_image
		fi

		if use benchmark_model; then
			einfo "Install benchmark_model tool"
			dobin bazel-bin/tensorflow/lite/tools/benchmark/benchmark_model
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

	fi

	einstalldocs
}
