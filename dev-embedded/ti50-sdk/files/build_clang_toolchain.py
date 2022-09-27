#!/usr/bin/env python3
# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
"""Builds the clang toolchain for Ti50."""

import argparse
import logging
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
from typing import List

# CFlags used when building RISCV runtime libraries.
RISCV_RUNTIME_CFLAGS = (
    '-O2',
    '--target=riscv32-unknown-elf',
    '-DVISIBILITY_HIDDEN',
    '-DNDEBUG',
    '-fno-builtin',
    '-fvisibility=hidden',
    '-fomit-frame-pointer',
    '-mno-relax',
    '-fforce-enable-int128',
    '-DCRT_HAS_INITFINI_ARRAY',
    '-march=rv32imcxsoteria',
    '-ffunction-sections',
    '-fdata-sections',
    '-fstack-size-section',
    '-mcmodel=medlow',
    '-Wno-unused-command-line-argument',
)

# Flags passed to cmake command for building LLVM
# TODO(sukhomlinov): These args are copy-pasted; they might not all be
# necessary.
CMAKE_FLAGS = (
    '-G',
    'Ninja',
    '-DCMAKE_BUILD_TYPE=Release',
    '-DLLVM_ENABLE_LIBCXX=ON',
    '-DLLVM_OPTIMIZED_TABLEGEN=ON',
    '-DLLVM_BUILD_TESTS=OFF',
    '-DCLANG_ENABLE_STATIC_ANALYZER=ON',
    '-DCLANG_DEFAULT_RTLIB="compiler-rt"',
    '-DLLVM_DEFAULT_TARGET_TRIPLE=riscv32-unknown-elf',
    '-DLLVM_INSTALL_BINUTILS_SYMLINKS=ON',
    '-DLLVM_INSTALL_CCTOOLS_SYMLINKS=ON',
    '-DCLANG_DEFAULT_LINKER=ld.lld',
    '-DLLVM_ENABLE_BACKTRACES=OFF',
    '-DLLVM_INCLUDE_EXAMPLES=OFF',
    '-DLLVM_DYLIB_COMPONENTS=""',
    '-DLLVM_LINK_LLVM_DYLIB=OFF',
    '-DLLVM_BUILD_STATIC=OFF',
    '-DLLVM_INSTALL_UTILS=ON',
    '-DLLVM_ENABLE_Z3_SOLVER=OFF',
    '-DLLVM_USE_RELATIVE_PATHS_IN_FILES=ON',
    '-DLLVM_TARGETS_TO_BUILD=RISCV;X86',
    '-DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra;lldb;lld;polly',
)

# Flags for configuring newlib.
NEWLIB_CONFIG_FLAGS = (
    '--target=riscv32-unknown-elf',
    '--enable-newlib-reent-small',
    '--disable-newlib-fvwrite-in-streamio',
    '--disable-newlib-fseek-optimization',
    '--disable-newlib-wide-orient',
    '--enable-newlib-nano-malloc',
    '--disable-newlib-unbuf-stream-opt',
    '--enable-lite-exit',
    '--enable-newlib-global-atexit',
    '--enable-newlib-nano-formatted-io',
    '--disable-newlib-supplied-syscalls',
    '--disable-nls',
    '--enable-newlib-io-c99-formats',
    '--enable-newlib-io-long-long',
)


def remove_path_if_exists(file_or_dir: Path):
  """Removes the given file/directory/symlink if it exists."""
  if file_or_dir.is_file() or file_or_dir.is_symlink():
    file_or_dir.unlink()
  elif file_or_dir.is_dir():
    shutil.rmtree(file_or_dir)
  else:
    assert not file_or_dir.exists(), file_or_dir


def find_clang_resource_dir(llvm_install_dir: Path) -> Path:
  """Locates the resource directory of the clang in |llvm_install_dir|."""
  return Path(
      subprocess.check_output(
          [str(llvm_install_dir / 'bin' / 'clang'), '-print-resource-dir'],
          encoding='utf-8',
      ).strip())


def build_llvm(llvm_dir: Path, build_dir: Path, install_dir: Path):
  """Builds and installs LLVM to install_dir, plus crt{begin,end} for RISCV."""
  build_dir.mkdir(parents=True, exist_ok=True)

  if not (build_dir / 'build.ninja').exists():
    logging.info('Configuring LLVM')
    cmd = [
        'cmake',
        f'-DCMAKE_INSTALL_PREFIX={install_dir}',
        f'-DDEFAULT_SYSROOT={install_dir}',
        f'-DGCC_INSTALL_PREFIX={install_dir}',
        str(llvm_dir / 'llvm'),
    ]
    cmd += CMAKE_FLAGS
    subprocess.check_call(cmd, cwd=build_dir)

  logging.info('Building + installing LLVM')
  subprocess.check_call(['ninja', 'install'], cwd=build_dir)

  # And now we build the runtime library. Whee.
  clang_rtlib_prefix = [
      str(install_dir / 'bin' / 'clang'),
      '-c',
      '-v',
  ]
  clang_rtlib_prefix += RISCV_RUNTIME_CFLAGS

  libdir = find_clang_resource_dir(install_dir)
  (libdir / 'lib').mkdir(parents=True, exist_ok=True)
  subprocess.check_call(clang_rtlib_prefix + [
      str(llvm_dir / 'compiler-rt' / 'lib' / 'crt' / 'crtbegin.c'),
      '-o',
      str(libdir / 'lib' / 'clang_rt.crtbegin-riscv32.o'),
  ])

  subprocess.check_call(clang_rtlib_prefix + [
      str(llvm_dir / 'compiler-rt' / 'lib' / 'crt' / 'crtend.c'),
      '-o',
      str(libdir / 'lib' / 'clang_rt.crtend-riscv32.o'),
  ])


def build_newlib(rv_clang_bin: Path, newlib_dir: Path, newlib_build_dir: Path,
                 install_dir: Path):
  """Builds and installs newlib into |install_dir|."""
  newlib_build_dir.mkdir(parents=True)

  logging.info("Setting up newlib's build")

  env_with_rv_clang = os.environ.copy()
  # ...I don't *want* to have all of this in the environment, but if all of
  # this (ignoring PATH) is provided to |./configure| as args, |make| gets
  # angry that it doesn't see the same values in its environment when invoked.
  #
  # TODO(sukhomlinov): This seems like brokenness in newlib, maybe?
  env_with_rv_clang.update({
      'LDFLAGS': f'{env_with_rv_clang.get("LDFLAGS", "")} -fuse-ld=lld',
      'PATH': f'{rv_clang_bin}:{env_with_rv_clang["PATH"]}',
  })

  tool_substitutions = (
      ('AR', 'llvm-ar'),
      ('AS', 'llvm-as'),
      ('NM', 'llvm-nm'),
      ('OBJDUMP', 'llvm-objdump'),
      ('RANLIB', 'llvm-ranlib'),
  )

  for var_name, executable in tool_substitutions:
    executable_path = install_dir / 'bin' / executable
    env_with_rv_clang.update({
        var_name: executable_path,
        f'{var_name}_FOR_TARGET': executable_path,
    })

  env_with_rv_clang.update({
      f'{var_name}_FOR_TARGET': install_dir / 'bin' / exe
      for var_name, exe in (('CC', 'clang'), ('CXX', 'clang++'))
  })

  cmd = [
      './configure',
      f'--prefix={newlib_build_dir}',
      f'CFLAGS_FOR_TARGET={" ".join(RISCV_RUNTIME_CFLAGS)}',
      f'CXXFLAGS_FOR_TARGET={" ".join(RISCV_RUNTIME_CFLAGS)}',
      'LDFLAGS=-fuse-ld=lld',
      'LDFLAGS_FOR_TARGET=-fuse-ld=lld',
  ]
  cmd += NEWLIB_CONFIG_FLAGS
  subprocess.check_call(cmd, cwd=newlib_dir, env=env_with_rv_clang)

  logging.info('Building newlib')

  jobs = f'-j{os.cpu_count()}'
  subprocess.check_call(['make', jobs], cwd=newlib_dir, env=env_with_rv_clang)
  subprocess.check_call(['make', jobs, 'install'],
                        cwd=newlib_dir,
                        env=env_with_rv_clang)

  logging.info("Fixing newlib's installation")
  # Quoting the script that I'm basing this off of:
  # """
  # move includes/libs to where they can be found by default
  # this is also a hack, but avoid adding paths explicitly
  # This is because riscv32-unknown-elf target only use
  # $INSTALL_DIR/lib and $INSTALL_DIR/lib/clang/11.0.0/lib paths,
  # ignoring --libdir and --sysroot for cmake configure
  # $INSTALL_DIR/include contains llvm headers not used for C compilation
  # normally, unless you build llvm tools, but directory is in default
  # search path, so use it for libc headers.
  # """
  installed_include_dir = install_dir / 'include'
  old_include_dir = install_dir / 'include.old'
  if installed_include_dir.exists():
    shutil.move(installed_include_dir, old_include_dir)

  shutil.copytree(newlib_build_dir / 'riscv32-unknown-elf' / 'include',
                  installed_include_dir)

  if old_include_dir.exists():
    shutil.rmtree(old_include_dir)
  for f in (install_dir / 'lib').glob('*.a'):
    f.unlink()

  lib_base = install_dir / 'lib'
  for f in (newlib_build_dir / 'riscv32-unknown-elf' / 'lib').iterdir():
    shutil.copy2(f, lib_base / f.name)


def build_compiler_rt(llvm_path: Path, compiler_rt_build_dir: Path,
                      install_dir: Path):
  """Builds compiler_rt and installs artifacts in |install_dir|."""
  compiler_rt_build_dir.mkdir(parents=True)
  run_clang = [str(install_dir / 'bin' / 'clang'), '-c']
  run_clang += RISCV_RUNTIME_CFLAGS
  compiler_rt_builtins = llvm_path / 'compiler-rt' / 'lib' / 'builtins'
  subprocess.check_call(
      run_clang + [
          str(compiler_rt_builtins / 'riscv' / 'mulsi3.S'),
      ],
      cwd=compiler_rt_build_dir,
  )

  # It's expected that some of these builds fail for various reasons (no atomic
  # uint64_t on riscv, etc.)
  expected_failures = {
      'atomic_flag_clear.c',
      'atomic_flag_clear_explicit.c',
      'atomic_flag_test_and_set.c',
      'atomic_flag_test_and_set_explicit.c',
      'atomic_signal_fence.c',
      'atomic_thread_fence.c',
      'emutls.c',
      'enable_execute_stack.c',
  }

  had_unexpected_results = False
  for f in compiler_rt_builtins.glob('*.c'):
    # Build the expected failures, since doing so is quick, and if they _do_
    # successfully build, that sounds like smoke to me.
    command = run_clang + [str(f)]
    should_fail = f.name in expected_failures
    command_string = ' '.join(shlex.quote(x) for x in command)
    try:
      stdout = subprocess.check_output(
          command,
          cwd=compiler_rt_build_dir,
          stderr=subprocess.STDOUT,
          encoding='utf-8',
      )
    except subprocess.CalledProcessError as e:
      if should_fail:
        logging.info('Running %s failed as expected', command_string)
        continue
      logging.error('Running %s failed unexpectedly; output:\n%s',
                    command_string, e.stdout)
      had_unexpected_results = True
    else:
      if not should_fail:
        logging.info('Running %s succeeded as expected', command_string)
        continue
      logging.error('Running %s succeeded unexpectedly; output:\n%s',
                    command_string, stdout)
      had_unexpected_results = True

  if had_unexpected_results:
    raise ValueError(
        "Manual builds of compiler-rt bits didn't go as planned; please see "
        'logging output')

  libdir = find_clang_resource_dir(install_dir)
  link_command = [
      str(install_dir / 'bin' / 'llvm-ar'),
      'rc',
      str(libdir / 'libclang_rt.builtins-riscv32.a'),
  ]
  link_command += (str(x) for x in compiler_rt_build_dir.glob('*.o'))
  subprocess.check_call(link_command)


def log_install_paths(install_dir: Path):
  """Prints install paths to stdout."""
  clang = str(install_dir / 'bin' / 'clang')
  subprocess.check_call([clang, '-E', '-x', 'c++', '/dev/null', '-v'])
  subprocess.check_call([clang, '-print-search-dirs'])


def get_parser():
  """Creates a parser for commandline args."""
  parser = argparse.ArgumentParser(
      description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
  parser.add_argument(
      '--work-dir',
      required=True,
      type=Path,
      help='Path to put build artifacts in.',
  )
  parser.add_argument(
      '--llvm-dir',
      required=True,
      type=Path,
      help='Path to the LLVM checkout.',
  )
  parser.add_argument(
      '--newlib-dir',
      required=True,
      type=Path,
      help='Path to the newlib checkout.',
  )
  parser.add_argument(
      '--no-clean-llvm',
      action='store_false',
      dest='clean_llvm',
      help="Don't wipe out LLVM's build directory if it exists.",
  )
  parser.add_argument(
      '--no-clean-newlib',
      action='store_false',
      dest='clean_newlib',
      help="Don't wipe out newlib's build directory if it exists.",
  )
  parser.add_argument(
      '--install-dir',
      required=True,
      type=Path,
      help='Path to the place to install artifacts.',
  )
  return parser


def main(argv: List[str]):
  logging.basicConfig(
      format='%(asctime)s: %(levelname)s: %(filename)s:%(lineno)d: %(message)s',
      level=logging.INFO,
  )

  opts = get_parser().parse_args(argv)
  work_dir = opts.work_dir
  install_dir = opts.install_dir.resolve()
  llvm_path = opts.llvm_dir.resolve()
  newlib_path = opts.newlib_dir.resolve()

  work_dir.mkdir(parents=True, exist_ok=True)

  remove_path_if_exists(install_dir)
  install_dir.mkdir(parents=True)

  llvm_build_dir = work_dir / 'llvm-build' / 'Release'
  if opts.clean_llvm:
    remove_path_if_exists(llvm_build_dir)
  build_llvm(llvm_path, llvm_build_dir, install_dir)

  newlib_build_dir = work_dir / 'newlib' / 'build'
  if opts.clean_newlib:
    # Ugly: newlib builds to _both_ the build dir and an in-git-directory dir;
    # would be nice if it only used one.
    remove_path_if_exists(newlib_build_dir)
    # In an |emerge| flow, we don't need this, but repeated |ebuild|s could
    # leave us with a dirty source directory.
    if (newlib_path / 'Makefile').exists():
      remove_path_if_exists(newlib_path / 'riscv32-unknown-elf')
      subprocess.check_call(['make', 'distclean'], cwd=newlib_path)

  build_newlib(
      rv_clang_bin=install_dir / 'bin',
      newlib_dir=newlib_path,
      newlib_build_dir=newlib_build_dir,
      install_dir=install_dir,
  )

  compiler_rt_build_dir = work_dir / 'compiler-rt-build'
  remove_path_if_exists(compiler_rt_build_dir)
  build_compiler_rt(llvm_path, compiler_rt_build_dir, install_dir)

  log_install_paths(install_dir)


if __name__ == '__main__':
  sys.exit(main(sys.argv[1:]))
