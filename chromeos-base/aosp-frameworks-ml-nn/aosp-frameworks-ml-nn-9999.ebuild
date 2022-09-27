# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cros-constants

CROS_WORKON_PROJECT=(
	"chromiumos/platform2"
	"aosp/platform/frameworks/ml"
	"aosp/platform/hardware/interfaces/neuralnetworks"
)
CROS_WORKON_REPO=(
	"${CROS_GIT_HOST_URL}"
	"${CROS_GIT_HOST_URL}"
	"${CROS_GIT_HOST_URL}"
)
CROS_WORKON_EGIT_BRANCH=(
	"main"
	"master"
	"master"
)
CROS_WORKON_LOCALNAME=(
	"platform2"
	"aosp/frameworks/ml"
	"aosp/hardware/interfaces/neuralnetworks"
)
CROS_WORKON_DESTDIR=(
	"${S}/platform2"
	"${S}/platform2/aosp/frameworks/ml"
	"${S}/platform2/aosp/hardware/interfaces/neuralnetworks"
)
CROS_WORKON_SUBTREE=(
	"common-mk .gn"
	""
	""
)

PLATFORM_SUBDIR="aosp/frameworks/ml"

inherit cros-workon platform flag-o-matic

DESCRIPTION="Chrome OS port of the Android Neural Network API"
HOMEPAGE="https://developer.android.com/ndk/guides/neuralnetworks"

LICENSE="BSD-Google Apache-2.0"
KEYWORDS="~*"
IUSE="cpu_flags_x86_avx2 vendor-nnhal minimal-driver xnnpack-driver"

RDEPEND="
	chromeos-base/nnapi:=
	dev-libs/openssl:=
	sci-libs/tensorflow:=
"

DEPEND="
	${RDEPEND}
	dev-libs/libtextclassifier
	>=dev-cpp/eigen-3
"

src_configure() {
	if use x86 || use amd64; then
		append-cppflags "-D_Float16=__fp16"
		append-cxxflags "-Xclang -fnative-half-type"
		append-cxxflags "-Xclang -fallow-half-arguments-and-returns"
	fi
	if use xnnpack-driver; then
		append-cppflags "-DNNAPI_USE_XNNPACK_DRIVER"
	fi
	if use minimal-driver; then
		append-cppflags "-DNNAPI_USE_MINIMAL_DRIVER"
	fi
	platform_src_configure
}

platform_pkg_test() {
	local tests=(
		chromeos common runtime runtime_generated
	)
	local gtest_excl_filter="-"
	local qemu_gtest_excl_filter="-"

	# These tests fail with Tensorflow 2.5.0. Don't want to block
	# the uprev on that, since nothing in production is using this
	# package yet. Tracking this test failure in following bug.
	# TODO: b/189803299
	gtest_excl_filter+="TestGenerated/*.Test/svdf_bias_present*:"
	qemu_gtest_excl_filter+="TestGenerated/*.Test/svdf_bias_present*:"

	# When running in qemu, these tests freeze the emulator when hitting
	# EventFlag::wake from libfmq. The error printed is:
	# Error in event flag wake attempt: Function not implemented
	# This is a known issue, see:
	# https://chromium.googlesource.com/chromiumos/docs/+/master/testing/running_unit_tests.md#caveats
	# TODO(http://crbug.com/1117470): tracking bug for qemu fix
	qemu_gtest_excl_filter+="Flavor/ExecutionTest10.Wait*:"
	qemu_gtest_excl_filter+="Flavor/ExecutionTest11.Wait*:"
	qemu_gtest_excl_filter+="Flavor/ExecutionTest12.Wait*:"
	qemu_gtest_excl_filter+="Flavor/ExecutionTest13.Wait*:"
	qemu_gtest_excl_filter+="IntrospectionFlavor/ExecutionTest13.Wait*:"
	qemu_gtest_excl_filter+="Unfenced/TimingTest.Test/12:"
	qemu_gtest_excl_filter+="Unfenced/TimingTest.Test/15:"
	qemu_gtest_excl_filter+="Unfenced/TimingTest.Test/18:"
	qemu_gtest_excl_filter+="Unfenced/TimingTest.Test/21:"
	qemu_gtest_excl_filter+="Unfenced/TimingTest.Test/24:"
	qemu_gtest_excl_filter+="ValidationTestBurst.BurstComputeBadCompilation:"
	qemu_gtest_excl_filter+="ValidationTestBurst.BurstComputeConcurrent:"
	qemu_gtest_excl_filter+="ValidationTestBurst.BurstComputeDifferentCompilations:"
	qemu_gtest_excl_filter+="ValidationTestBurst.BurstComputeNull:"
	qemu_gtest_excl_filter+="ValidationTestBurst.FreeBurstBeforeMemory:"
	qemu_gtest_excl_filter+="ValidationTestBurst.FreeMemoryBeforeBurst:"
	qemu_gtest_excl_filter+="ValidationTestCompilation.ExecutionUsability:"
	qemu_gtest_excl_filter+="ValidationTestCompilation.ReusableExecutionConcurrent:"
	qemu_gtest_excl_filter+="ValidationTestCompilation.NonReusableExecutionConcurrent:"
	qemu_gtest_excl_filter+="ValidationTestCompilationForDevices_1.ExecutionTiming:"
	qemu_gtest_excl_filter+="ValidationTestCompilationForDevices_1.ExecutionSetTimeout:"
	qemu_gtest_excl_filter+="ValidationTestCompilationForDevices_1.ExecutionSetTimeoutMaximum:"

	if use asan; then
		# Some tests do not correctly clean up the Execution object and it is
		# left 'in-flight', which gets ignored by ANeuralNetworksExecution_free.
		# See b/161844605.
		# Look for 'passed an in-flight ANeuralNetworksExecution' in log output
		gtest_excl_filter+="Fenced/TimingTest.Test/2:"
		gtest_excl_filter+="Fenced/TimingTest.Test/19:"
		gtest_excl_filter+="Flavor/ExecutionTest10.Wait/1:"
		gtest_excl_filter+="Flavor/ExecutionTest10.Wait/2:"
		gtest_excl_filter+="Flavor/ExecutionTest10.Wait/4:"
		gtest_excl_filter+="Flavor/ExecutionTest11.Wait/1:"
		gtest_excl_filter+="Flavor/ExecutionTest11.Wait/2:"
		gtest_excl_filter+="Flavor/ExecutionTest11.Wait/4:"
		gtest_excl_filter+="Flavor/ExecutionTest12.Wait/1:"
		gtest_excl_filter+="Flavor/ExecutionTest12.Wait/2:"
		gtest_excl_filter+="Flavor/ExecutionTest12.Wait/4:"
		gtest_excl_filter+="Flavor/ExecutionTest13.Wait/1:"
		gtest_excl_filter+="Flavor/ExecutionTest13.Wait/2:"
		gtest_excl_filter+="Flavor/ExecutionTest13.Wait/4:"
		gtest_excl_filter+="IntrospectionFlavor/ExecutionTest13.Wait/1:"
		gtest_excl_filter+="IntrospectionFlavor/ExecutionTest13.Wait/2:"
		gtest_excl_filter+="IntrospectionFlavor/ExecutionTest13.Wait/4:"

		# This is due to a leak caused when copying the memory pools
		# into the request object in this test. lsan_suppressions doesn't
		# work due to the lack of /usr/bin/llvm-symbolizer, so just exclude.
		gtest_excl_filter+="ComplianceTest.DeviceMemory:"
		gtest_excl_filter+="ValidateRequestTest.ScalarOutput:"
		gtest_excl_filter+="ValidateRequestTest.UnknownOutputRank:"

		# Buffer overflow here, but seems to be expected?
		gtest_excl_filter+="OperandExtraParamsTest.TestChannelQuantValuesBadScalesCount:"

		# Leaks in CPUExecutor
		gtest_excl_filter+="*RandomPartitioningTest*:"

		# Disable asan container overflow checks that are coming from gtest,
		# not our code. Strangely this only started happening once we made
		# common a shared library.
		# See: https://crbug.com/1067977, https://crbug.com/1069722
		# https://github.com/google/sanitizers/wiki/AddressSanitizerContainerOverflow#false-positives
		export ASAN_OPTIONS+=":detect_container_overflow=0:detect_odr_violation=0:"
	fi
	if use xnnpack-driver; then
		# These tests don't currently work with the XNNPACK driver
		gtest_excl_filter+="ValidationTestExecutionDeviceMemory.SetInputFromMemory*:"
		gtest_excl_filter+="ValidationTestExecutionDeviceMemory.SetOutputFromMemory*:"
		gtest_excl_filter+="TestGenerated/*.Test/maximum_broadcast*:"
		gtest_excl_filter+="TestGenerated/*.Test/maximum_simple*:"
		gtest_excl_filter+="TestGenerated/*.Test/minimum_broadcast*:"
		gtest_excl_filter+="TestGenerated/*.Test/minimum_simple*:"
		gtest_excl_filter+="TestGenerated/*.Test/pad*:"
		gtest_excl_filter+="TestGenerated/*.Test/prelu*:"
		gtest_excl_filter+="TestGenerated/*.Test/resize_bilinear_v1_3_align_corners*:"
		gtest_excl_filter+="TestGenerated/*.Test/depthwise_conv2d_invalid_filter_dims_nhwc*:"
		gtest_excl_filter+="TestGenerated/DeviceMemoryTest.Test/*:"
	fi
	local test_target
	for test_target in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_target}_testrunner" "0" "${gtest_excl_filter}" "${qemu_gtest_excl_filter}"
	done

	if use xnnpack-driver; then
		platform_test "run" "${OUT}/runtime_xnn_testrunner"
	fi
}

src_compile() {
	platform_src_compile
	if use xnnpack-driver; then
		platform "compile" "xnn-driver"
		platform "compile" "runtime_xnn_testrunner"
	fi
}

src_install() {
	einfo "Installing runtime & common Headers."
	insinto /usr/include/aosp/frameworks/ml/nn/common
	doins -r "${S}"/common/include
	insinto /usr/include/aosp/frameworks/ml/nn/runtime
	doins -r "${S}"/runtime/include
	insinto /usr/include/aosp/frameworks/ml/nn/driver/cache
	doins "${S}"/driver/cache/nnCache/nnCache.h
	doins "${S}"/driver/cache/BlobCache/BlobCache.h

	einfo "Installing libs."
	dolib.so "${OUT}/lib/libneuralnetworks.so"
	dolib.so "${OUT}/lib/libnn-common.so"

	einfo "Installing default driver"
	dolib.so "${OUT}/lib/libfull-driver.so"

	if ! use vendor-nnhal ; then
		einfo "Installing reference vendor hal."
		dolib.so "${OUT}/lib/libvendor-nn-hal.so"
	fi
	if use minimal-driver; then
		einfo "Installing minimal drivers"
		dolib.so "${OUT}/lib/libminimal-driver.so"
	fi
	if use xnnpack-driver; then
		einfo "Installing xnnpack drivers"
		dolib.so "${OUT}/lib/libxnn-driver.so"
	fi
}
