#!/bin/bash

cd $SIMPATH/basics

if [ ! -d  $SIMPATH/basics/msgpack ];
then
  git clone $MSGPACK_LOCATION msgpack
fi

checkfile=$SIMPATH_INSTALL/include/msgpack.hpp

if (not_there msgpack $checkfile);
then
  cd msgpack
  git checkout $MSGPACK_VERSION
  if [ ! -d  build ];
  then
    mkdir build
  fi
  cd build
  cmake -DCMAKE_INSTALL_PREFIX=$SIMPATH_INSTALL \
        -DCMAKE_PREFIX_PATH=$SIMPATH_INSTALL \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
        -DCMAKE_CXX_COMPILER=$CXX \
        -DCMAKE_C_COMPILER=$CC \
        -DMSGPACK_CXX11=ON \
        -DMSGPACK_BUILD_TESTS=OFF \
        ..
  cmake --build . --target install -- -j$number_of_processes
fi
check_success msgpack $checkfile
check=$?

cd $SIMPATH
return 1
