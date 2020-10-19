#! /bin/bash

set -e
set -x

export SIMPATH="@CMAKE_INSTALL_PREFIX@"
git clone -b v18.4.1 https://github.com/FairRootGroup/FairRoot_v18.4.1
pushd FairRoot_v18.4.1
export FAIRROOTPATH="$(realpath ./install)"
cmake -S. -Bbuild \
  -DCMAKE_INSTALL_PREFIX=$FAIRROOTPATH
cmake --build build --target install -j@NCPUS@
pushd build
ctest --output-on-failure
popd
popd
