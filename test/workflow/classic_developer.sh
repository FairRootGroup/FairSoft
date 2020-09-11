#! /bin/bash

set -e
set -x

if [[ "$ENVNAME" =~ jun19 ]]
then
  no_boost_cmake=1
fi

unset FAIRSOFT_ROOT
export SIMPATH="$(realpath ./fairsoft)"
cmake="$SIMPATH/bin/cmake"
ctest="$SIMPATH/bin/ctest"

if [ "$(uname)" = Darwin ]
then
  extra_excludes="-e libpng -e libjpeg-turbo -e libiconv -e sqlite"
fi
spack view --dependencies true $extra_excludes -e fairroot symlink -i $SIMPATH fairroot cmake

git clone --branch dev https://github.com/FairRootGroup/FairRoot
pushd FairRoot
export FAIRROOTPATH="$(realpath ./install)"
$cmake -S. -Bbuild \
  -DUSE_DIFFERENT_COMPILER=ON \
  ${no_boost_cmake:+-DBoost_NO_BOOST_CMAKE=ON} \
  -DCMAKE_INSTALL_PREFIX=$FAIRROOTPATH
$cmake --build build --target install -j $SPACK_BUILD_JOBS
pushd build
# Excluding the geant3 tests because they just fail too often,
# see https://github.com/FairRootGroup/FairRoot/issues/995
$ctest --output-on-failure -E TGeant3 -E sim_tutorial2 -E MQ_pixel
popd
popd
