#! /bin/bash

set -e
set -x

export SIMPATH="@CMAKE_INSTALL_PREFIX@"
version=v18.4.2
sourcedir=FairRoot_${version}
git clone -b ${version} https://github.com/FairRootGroup/FairRoot $sourcedir
pushd $sourcedir
export FAIRROOTPATH="$(realpath ./install)"
cmake -S. -Bbuild \
  -DCMAKE_INSTALL_PREFIX=$FAIRROOTPATH
cmake --build build --target install -j @NCPUS@
pushd build
ctest --output-on-failure -j @NCPUS@
popd
