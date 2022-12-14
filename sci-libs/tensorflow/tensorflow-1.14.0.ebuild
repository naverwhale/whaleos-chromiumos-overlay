# Copyright 1999-2019 Jason Zaman
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_OPTIONAL=1
PYTHON_COMPAT=( python2_7 python{3_5,3_6,3_7} )
MY_PV=${PV/_rc/-rc}
MY_P=${PN}-${MY_PV}

inherit check-reqs cros-bazel cuda distutils-r1 flag-o-matic toolchain-funcs

DESCRIPTION="Computation framework using data flow graphs for scalable machine learning"
HOMEPAGE="https://www.tensorflow.org/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="cuda mpi minimal +python label_image benchmark_model"
CPU_USE_FLAGS_X86="sse sse2 sse3 sse4_1 sse4_2 avx avx2 fma3 fma4"
for i in $CPU_USE_FLAGS_X86; do
	IUSE+=" cpu_flags_x86_$i"
done

# distfiles that bazel uses for the workspace, will be copied to basel-distdir
bazel_external_uris="
	http://www.kurims.kyoto-u.ac.jp/~ooura/fft.tgz -> oourafft-20061228.tgz
	https://bitbucket.org/eigen/eigen/get/a0d250e79c79.tar.gz -> eigen-a0d250e79c79.tar.gz
	https://github.com/abseil/abseil-cpp/archive/daf381e8535a1f1f1b8a75966a74e7cca63dee89.tar.gz -> abseil-cpp-daf381e8535a1f1f1b8a75966a74e7cca63dee89.tar.gz
	https://github.com/bazelbuild/bazel-skylib/archive/0.6.0.tar.gz -> bazel-skylib-0.6.0.tar.gz
	https://github.com/bazelbuild/rules_closure/archive/cf1e44edb908e9616030cc83d085989b8e6cd6df.tar.gz -> bazelbuild-rules_closure-cf1e44edb908e9616030cc83d085989b8e6cd6df.tar.gz
	https://github.com/bazelbuild/rules_docker/archive/b8ff6a85ec359db3fd5657accd3e524daf12016d.tar.gz -> rules_docker-b8ff6a85ec359db3fd5657accd3e524daf12016d.tar.gz
	https://github.com/bazelbuild/rules_swift/releases/download/0.9.0/rules_swift.0.9.0.tar.gz -> bazelbuild-rules_swift.0.9.0.tar.gz
	https://github.com/google/farmhash/archive/816a4ae622e964763ca0862d9dbd19324a1eaf45.tar.gz -> farmhash-816a4ae622e964763ca0862d9dbd19324a1eaf45.tar.gz
	https://github.com/google/gemmlowp/archive/12fed0cd7cfcd9e169bf1925bc3a7a58725fdcc3.zip -> gemmlowp-12fed0cd7cfcd9e169bf1925bc3a7a58725fdcc3.zip
	https://github.com/google/highwayhash/archive/fd3d9af80465e4383162e4a7c5e2f406e82dd968.tar.gz -> highwayhash-fd3d9af80465e4383162e4a7c5e2f406e82dd968.tar.gz
	https://github.com/intel/ARM_NEON_2_x86_SSE/archive/1200fe90bb174a6224a525ee60148671a786a71f.tar.gz -> ARM_NEON_2_x86_SSE-1200fe90bb174a6224a525ee60148671a786a71f.tar.gz
	https://github.com/nlopezgi/bazel-toolchains/archive/94d31935a2c94fe7e7c7379a0f3393e181928ff7.tar.gz -> bazel-toolchains-94d31935a2c94fe7e7c7379a0f3393e181928ff7.tar.gz
	cuda? (
		https://github.com/nvidia/nccl/archive/f93fe9bfd94884cec2ba711897222e0df5569a53.tar.gz -> nvidia-nccl-f93fe9bfd94884cec2ba711897222e0df5569a53.tar.gz
		https://github.com/NVlabs/cub/archive/1.8.0.zip -> cub-1.8.0.zip
	)
	python? (
		http://mirror.tensorflow.org/docs.python.org/2.7/_sources/license.rst.txt -> tensorflow-1.14.0-python-license.rst.txt
		https://pypi.python.org/packages/bc/cc/3cdb0a02e7e96f6c70bd971bc8a90b8463fda83e264fa9c5c1c98ceabd81/backports.weakref-1.0rc1.tar.gz
	)"

SRC_URI="https://github.com/${PN}/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz
		${bazel_external_uris}"

RDEPEND="
	>=dev-libs/flatbuffers-1.8.0:=
	>=dev-libs/protobuf-3.6.0:=
	!minimal? (
		app-arch/snappy
		dev-db/lmdb
		dev-db/sqlite
		dev-libs/icu
		>=dev-libs/jsoncpp-1.8.4
		dev-libs/libpcre
		dev-libs/nsync
		dev-libs/openssl:0=
		>=dev-libs/re2-0.2018.04.01
		media-libs/giflib
		media-libs/libjpeg-turbo
		media-libs/libpng:0
		>=net-libs/grpc-1.16.0
		net-misc/curl
		sys-libs/zlib
		>=sys-apps/hwloc-2
	)
	cuda? (
		>=dev-util/nvidia-cuda-toolkit-9.1[profiler]
		dev-libs/cudnn
	)
	mpi? ( virtual/mpi )
	python? (
		${PYTHON_DEPS}
		dev-python/absl-py[${PYTHON_USEDEP}]
		>=dev-python/astor-0.7.1[${PYTHON_USEDEP}]
		dev-python/gast[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/google-pasta[${PYTHON_USEDEP}]
		>=dev-python/protobuf-python-3.6.0[${PYTHON_USEDEP}]
		dev-python/six[${PYTHON_USEDEP}]
		dev-python/termcolor[${PYTHON_USEDEP}]
		dev-python/grpcio[${PYTHON_USEDEP}]
		>=dev-python/wrapt-1.11.1[${PYTHON_USEDEP}]
		>=net-libs/google-cloud-cpp-0.9.0
		>=sci-libs/keras-applications-1.0.6[${PYTHON_USEDEP}]
		>=sci-libs/keras-preprocessing-1.0.5[${PYTHON_USEDEP}]
		>=sci-visualization/tensorboard-1.13.0[${PYTHON_USEDEP}]
		virtual/python-enum34[${PYTHON_USEDEP}]
	)"
DEPEND="${RDEPEND}
	python? (
		dev-python/mock
	)"
PDEPEND="python? (
		>=sci-libs/tensorflow-estimator-1.13.0[${PYTHON_USEDEP}]
	)"
BDEPEND="
	app-arch/unzip
	>=dev-libs/flatbuffers-1.8.0
	>=dev-libs/protobuf-3.6.0
	|| (
		=dev-util/bazel-0.24*
		=dev-util/bazel-0.26*
		=dev-util/bazel-0.27*
	)
	cuda? (
		>=dev-util/nvidia-cuda-toolkit-9.1[profiler]
	)
	!python? ( dev-lang/python )
	python? (
		dev-lang/swig
		dev-python/grpcio-tools
		dev-python/mock
		dev-python/cython
	)"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} !minimal )"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}/tensorflow-1.14.0-0001-systemlibs-unbundle-enum34.patch"
	"${FILESDIR}/tensorflow-1.14.0-0002-linker-option-z-defs.patch"
	"${FILESDIR}/tensorflow-1.14.0-0003-eigen-include-sstream.patch"
	"${FILESDIR}/tensorflow-1.14.0-0004-neon-2-sse-header.patch"
	"${FILESDIR}/tensorflow-1.14.0-0005-nnapi-android-sdk-version.patch"
	"${FILESDIR}/tensorflow-1.14.0-0006-label-image-nnapi.patch"
	"${FILESDIR}/tensorflow-1.14.0-0007-flatbuffers-deps.patch"
)
DOCS=( AUTHORS CONTRIBUTING.md ISSUE_TEMPLATE.md README.md RELEASE.md )
CHECKREQS_MEMORY="5G"
CHECKREQS_DISK_BUILD="5G"

get-cpu-flags() {
	local i f=()
	# Keep this list in sync with tensorflow/core/platform/cpu_feature_guard.cc.
	for i in sse sse2 sse3 sse4_1 sse4_2 avx avx2 fma4; do
		use cpu_flags_x86_${i} && f+=( -m${i/_/.} )
	done
	use cpu_flags_x86_fma3 && f+=( -mfma )
	echo "${f[*]}"
}

# Echos the CPU string that TensorFlow uses to refer to the given architecture.
get-cpu-str() {
	local arch
	arch="$(tc-arch "${1}")"

	case "${arch}" in
	amd64) echo "k8";;
	arm) echo "arm";;
	arm64) echo "arm";;
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

	# 5 G to build C/C++ libs, 5G per python impl
	CHECKREQS_DISK_BUILD="$((5 + 5 * $num_pythons_enabled))G"
	check-reqs_pkg_setup
}

src_unpack() {
	# Only unpack the main distfile
	unpack "${P}.tar.gz"
	bazel_load_distfiles "${bazel_external_uris}"
}

src_prepare() {
	export JAVA_HOME=$(ROOT="${BROOT}" java-config --jdk-home)
	append-flags $(get-cpu-flags)

	# Exceptions are required for jsoncpp.
	! use minimal && cros_enable_cxx_exceptions

	# Can cause linker errors with full TF with relr relocations.
	if tc-ld-is-lld; then
		append-ldflags "-Wl,--pack-dyn-relocs=none"
	elif tc-ld-is-gold; then
		append-ldflags "-Wl,--no-experimental-use-relr"
	fi

	bazel_setup_bazelrc
	bazel_setup_crosstool "$(get-cpu-str "${CBUILD}")" "$(get-cpu-str "${CHOST}")"

	default
	use python && python_copy_sources

	use cuda && cuda_add_sandbox
}

src_configure() {

	do_configure() {
		export CC_OPT_FLAGS=" "
		export TF_ENABLE_XLA=0
		export TF_NEED_OPENCL_SYCL=0
		export TF_NEED_OPENCL=0
		export TF_NEED_COMPUTECPP=0
		export TF_NEED_ROCM=0
		export TF_NEED_MPI=$(usex mpi 1 0)
		export TF_SET_ANDROID_WORKSPACE=0

		if use python; then
			python_export PYTHON_SITEDIR
			export PYTHON_BIN_PATH="${PYTHON}"
			export PYTHON_LIB_PATH="${PYTHON_SITEDIR}"
		else
			export PYTHON_BIN_PATH="$(which python)"
			export PYTHON_LIB_PATH="$(python -c 'from distutils.sysconfig import *; print(get_python_lib())')"
		fi

		export TF_NEED_CUDA=$(usex cuda 1 0)
		export TF_DOWNLOAD_CLANG=0
		export TF_CUDA_CLANG=0
		export TF_NEED_TENSORRT=0
		if use cuda; then
			export TF_CUDA_PATHS="${EPREFIX%/}/opt/cuda"
			export GCC_HOST_COMPILER_PATH="$(cuda_gccdir)/$(tc-getCC)"
			export TF_CUDA_VERSION="$(cuda_toolkit_version)"
			export TF_CUDNN_VERSION="$(cuda_cudnn_version)"
			einfo "Setting CUDA version: $TF_CUDA_VERSION"
			einfo "Setting CUDNN version: $TF_CUDNN_VERSION"
		fi

		local SYSLIBS=(
			absl_py
			astor_archive
			boringssl
			com_github_googleapis_googleapis
			com_github_googlecloudplatform_google_cloud_cpp
			com_google_protobuf
			com_google_protobuf_cc
			com_googlesource_code_re2
			curl
			cython
			double_conversion
			enum34_archive
			flatbuffers
			gast_archive
			gif_archive
			grpc
			hwloc
			icu
			jpeg
			jsoncpp_git
			keras_applications_archive
			lmdb
			nasm
			nsync
			org_sqlite
			pasta
			pcre
			png_archive
			protobuf_archive
			six_archive
			snappy
			swig
			termcolor_archive
			wrapt
			zlib_archive
		)

		export TF_SYSTEM_LIBS="${SYSLIBS[@]}"
		export TF_IGNORE_MAX_BAZEL_VERSION=1

		# This is not autoconf
		./configure || die

		echo 'build --config=noaws --config=nohdfs --config=noignite --config=nokafka' >> .bazelrc || die
		echo 'build --define tensorflow_mkldnn_contraction_kernel=0' >> .bazelrc || die
		echo 'build --incompatible_no_support_tools_in_action_inputs=false' >> .bazelrc || die
	}
	if use python; then
		python_foreach_impl run_in_build_dir do_configure
	else
		do_configure
	fi
}

src_compile() {

	if use python; then
		python_setup
		BUILD_DIR="${S}-${EPYTHON/./_}"
		cd "${BUILD_DIR}"
	fi

	# fail early if any deps are missing
	ebazel build --nobuild \
		$(usex minimal '' '
			//tensorflow:libtensorflow_framework.so
			//tensorflow:libtensorflow.so
			//tensorflow:libtensorflow_cc.so') \
		//tensorflow/lite:libtensorflowlite.so \
		//tensorflow/lite/kernels/internal:install_nnapi_extra_headers \
		"$(usex label_image '
			//tensorflow/lite/examples/label_image:label_image' '')" \
		"$(usex benchmark_model '
			//tensorflow/lite/tools/benchmark:benchmark_model' '')" \
		"$(usex python '//tensorflow/tools/pip_package:build_pip_package' '')"

	ebazel build \
		$(usex minimal '' '
			//tensorflow:libtensorflow_framework.so
			//tensorflow:libtensorflow.so
			//tensorflow:libtensorflow_cc.so') \
		//tensorflow/lite:libtensorflowlite.so \
		//tensorflow/lite/kernels/internal:install_nnapi_extra_headers \
		"$(usex label_image '
			//tensorflow/lite/examples/label_image:label_image' '')" \
		"$(usex benchmark_model '
			//tensorflow/lite/tools/benchmark:benchmark_model' '')"

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

	if ! use minimal; then
		do_install() {
			einfo "Installing TF ${EPYTHON} files"
			local srcdir="${T}/src-${MULTIBUILD_VARIANT}"
			mkdir -p "${srcdir}" || die
			bazel-bin/tensorflow/tools/pip_package/build_pip_package --src "${srcdir}" || die
			cd "${srcdir}" || die
			esetup.py install

			# libtensorflow_framework.so is in /usr/lib already
			python_export PYTHON_SITEDIR PYTHON_SCRIPTDIR
			rm -f "${D}/${PYTHON_SITEDIR}"/${PN}/lib${PN}_framework.so* || die
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

		einfo "Installing TF headers"
		ebazel build //tensorflow:install_headers
		ebazel shutdown
		insinto /usr/include/${PN}/
		doins -r bazel-genfiles/tensorflow/include/*

		einfo "Installing TF libs"
		# Generate pkg-config file
		${PN}/c/generate-pc.sh --prefix="${EPREFIX}"/usr --libdir=$(get_libdir) --version=${MY_PV} || die
		insinto /usr/$(get_libdir)/pkgconfig
		doins ${PN}.pc

		for l in libtensorflow{,_framework,_cc}.so; do
			dolib.so bazel-bin/tensorflow/${l}
			dolib.so bazel-bin/tensorflow/${l}.$(ver_cut 1)
			dolib.so bazel-bin/tensorflow/${l}.$(ver_cut 1-3)
		done
	fi

	einfo "Installing TF lite headers"
	# From tensorflow/lite/lib_package/create_ios_frameworks.sh
	find ${PN}/lite -name "*.h" \
		-not -path "${PN}/lite/tools/*" \
		-not -path "${PN}/lite/examples/*" \
		-not -path "${PN}/lite/gen/*" \
		-not -path "${PN}/lite/toco/*" \
		-not -path "${PN}/lite/nnapi/*" \
		-not -path "${PN}/lite/java/*" |
	while read -r i; do
		insinto "/usr/include/${PN}/${i%/*}"
		doins "${i}"
	done
	if use minimal; then
		einfo "Installing selected TF core headers"
		local selected=( lib/bfloat16/bfloat16.h platform/byte_order.h platform/macros.h )
		for i in "${selected[@]}"; do
			insinto "/usr/include/${PN}/${PN}/core/${i%/*}"
			doins "${PN}/core/${i}"
		done
	fi

	einfo "Installing NNAPI headers"
	insinto /usr/include/${PN}/nnapi/
	doins -r bazel-genfiles/tensorflow/lite/kernels/internal/include

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

	einstalldocs
}
