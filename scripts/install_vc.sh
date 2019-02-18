#!/bin/bash

if [ ! -d  $SIMPATH/basics/Vc ]; then
  cd $SIMPATH/basics
  git clone $VC_LOCATION

  cd $SIMPATH/basics/Vc
  git checkout -b tag_$VC_TAG $VC_TAG
fi

install_prefix=$SIMPATH_INSTALL

checkfile=$install_prefix/lib/libVc.a

if (not_there Vc $checkfile);
then
    cd $SIMPATH/basics/Vc
    mkdir build
    cd build
    cmake -DCMAKE_C_COMPILER=$CC         \
          -DCMAKE_CXX_COMPILER=$CXX      \
          -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
          -DCMAKE_INSTALL_PREFIX=$SIMPATH_INSTALL \
          -DBUILD_TESTING=OFF            \
          ..

    make -j$number_of_processes
    make install

    check_all_libraries  $install_prefix/lib

    check_success Vc $checkfile
    check=$?

fi

cd $SIMPATH

return 1
