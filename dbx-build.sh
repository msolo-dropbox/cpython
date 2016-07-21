#!/bin/bash -eu

# bzl --build-image build_tools/docker/drbe-v1 cexec ./dbx-build.sh

if [ ! -d /dbxce ]; then
  echo "Run inside container:  bzl --build-image build_tools/docker/drbe-v1 cexec ./dbx-build.sh" >&2
  exit 1
fi

drte_py_prefix=/usr/drte/v1/python-2.7.12

autoconf
export LDFLAGS="-Wl,-rpath=/usr/drte/v1/lib/x86_64-linux-gnu:$drte_py_prefix/lib,--enable-new-dtags"
export CC=/usr/bin/gcc-4.9
./configure --prefix $drte_py_prefix --enable-unicode=ucs4

#CFLAGS="-g -fno-inline -fno-strict-aliasing"

make -j6 profile-opt PROFILE_TASK="-m test.regrtest -w -uall,-audio -x test_gdb test_multiprocessing"
sudo make -j1 install

cd $pkg_dir

tar czf ./drte-python-2.7.12.tgz $drte_py_prefix

# NOTE: We make the "version" a part of the name so we can have python-2.7.7 and python-2.7.10 installed simultaneously.
fpm -s tar -t deb -n "drte-v1-python-2.7.12" -v 1.0.0 ./drte-python-2.7.12.tgz
