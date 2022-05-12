#! /bin/bash

set -e
set -x

env | grep -i ctest
#for scrubvar in $(env | sed -n -e 's/=.*$//' -e '/CTEST/p')
#do
#  unset $scrubvar
#done

# Excluding the geant3 tests because they just fail too often,
# see https://github.com/FairRootGroup/FairRoot/issues/995
ctest_exclude_pattern="TGeant3|sim_tutorial2|MQ_pixel"

fairroot_branch=dev

case "$ENVNAME" in
  *jun19*)
    fairroot_branch=v18.6_patches
    extra_cmake_flags="-DBoost_NO_BOOST_CMAKE=ON -DUSE_DIFFERENT_COMPILER=ON"
    ;;
esac

case "$ENVNAME" in
  *)
    ctest_exclude_pattern="$ctest_exclude_pattern|pixelSplitDDS"
    ;;
esac


unset FAIRSOFT_ROOT
export SIMPATH="$(realpath ./fairsoft)"
cmake="$SIMPATH/bin/cmake"
ctest="$SIMPATH/bin/ctest"

if [ "$(uname)" = Darwin ]
then
  extra_excludes="-e libpng -e libjpeg-turbo -e libiconv -e sqlite"
fi
spack view --dependencies true $extra_excludes -e fairroot \
	symlink -i $SIMPATH fairroot faircmakemodules

git clone --branch "$fairroot_branch" https://github.com/FairRootGroup/FairRoot
pushd FairRoot
export FAIRROOTPATH="$(realpath ./install)"
$cmake -S. -Bbuild \
  -DCMAKE_RULE_MESSAGES=OFF -DCMAKE_INSTALL_MESSAGE=NEVER \
  ${extra_cmake_flags} \
  -DCMAKE_INSTALL_PREFIX=$FAIRROOTPATH
$cmake --build build --target install -j $SPACK_BUILD_JOBS
pushd build
$ctest --output-on-failure -E "$ctest_exclude_pattern"
popd
popd
