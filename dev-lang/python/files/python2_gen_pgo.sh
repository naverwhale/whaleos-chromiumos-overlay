#!/bin/bash -eu
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

my_dir="$(dirname "$(readlink -m "$0")")"
profiles_dir=/tmp/python_profiles
python=python2

ncpus="$(grep -c ^processor /proc/cpuinfo)"

if [[ "${UID}" -eq 0 ]]; then
  echo "Run me as non-root" >&2
  exit 1
fi

run_in_parallel() {
  local num_times="$1"
  local running=0
  shift

  for _ in $(seq 0 "${num_times}"); do
    if [[ "${running}" -gt "${ncpus}" ]]; then
      wait -n || :
    else
      : $(( running += 1 ))
    fi
    "$@" &
  done

  wait
}

# The following command should do whatever's representative of your regular
# Python workloads.
run_python() {
  # These were pretty unscientifically chosen. Just common Python-y
  # things that hopefully exercise hot paths in the interpreter.
  run_in_parallel 50 equery l \* >& /dev/null
  run_in_parallel 50 emerge --update --deep --with-bdeps=y --pretend \
    @world >& /dev/null
  run_in_parallel 50 equery g virtual/target-os --depth=0 >& /dev/null
}

if [[ -e "${profiles_dir}" ]]; then
  sudo rm -rf "${profiles_dir}"
fi

mkdir -p "${profiles_dir}"
chmod 777 "${profiles_dir}"

emerge_python() {
  sudo emerge dev-lang/python:2.7
}

# LLVM's profdata tool tries to create files with 0666, and we appear to have a
# default 022 umask in CrOS. Let it create world-writable things as much as
# possible.
umask -S 000

USE='pgo_generate -pgo_use' emerge_python

# Make everything here writable by everyone, so we don't have to deal with
# permissions errors/etc. Failing to write to a profile doesn't change a
# process' exit code, so it can be easy to miss.
sudo chmod -R ugo+rw "${profiles_dir}"

run_python

PV="$(equery list python:2.7 -F '$version')"
target="/tmp/python-${PV}-pgo-prof.profdata"
llvm-profdata merge -output="${target}" "${profiles_dir}"/*
sudo rm -rf "${profiles_dir}"

zipped_target="${target}.tar.xz"
cd "$(dirname "${target}")"
tar -cJf "${zipped_target}" "$(basename "${target}")"
rm -rf "${target}"

echo "Done. Your new profile is now available at ${zipped_target}."
echo "Please upload it to our localmirror, like so:"
echo "gsutil cp -n -a public-read '${zipped_target}'" \
  "gs://chromeos-localmirror/distfiles/python-${PV}-pgo-prof.profdata.tar.xz"
echo "Once that's complete, update python's manifests, and bump PROF_VERSION" \
  "in the ebuild."
