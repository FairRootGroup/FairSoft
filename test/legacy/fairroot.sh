#! /bin/bash

set -e
set -x

export SIMPATH="@CMAKE_INSTALL_PREFIX@"
version=v18.4.1
sourcedir=FairRoot_${version}
git clone -b v18.4.1 https://github.com/FairRootGroup/FairRoot $sourcedir
pushd $sourcedir
export FAIRROOTPATH="$(realpath ./install)"
# cmake -S. -Bbuild \
  # -DCMAKE_INSTALL_PREFIX=$FAIRROOTPATH
# cmake --build build --target install -j @NCPUS@
mkdir build
pushd build
cmake -DCMAKE_INSTALL_PREFIX=$FAIRROOTPATH ..
make install -j @NCPUS@
ctest --output-on-failure
popd
popd
