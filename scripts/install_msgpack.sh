#!/bin/bash

if [ ! -d  $SIMPATH/basics/msgpack ];
then
  cd $SIMPATH/basics
  echo "*** Downloading MessagePack sources ***"
  git clone $MSGPACK_LOCATION msgpack
  cd $SIMPATH/basics/msgpack
  git checkout -b $MSGPACK_BRANCH $MSGPACK_BRANCH
fi

install_prefix=$SIMPATH_INSTALL
checkfile=$install_prefix/lib/libmsgpackc.a

if (not_there MessagePack $checkfile);
then
    cd $SIMPATH/basics/msgpack

    mkdir -p build
    cd build

    cmake -DCMAKE_INSTALL_PREFIX=$install_prefix \
          -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
          -DCMAKE_CXX_COMPILER=$CXX \
          -DCMAKE_C_COMPILER=$CC \
          -DMSGPACK_CXX11=ON \
          -DMSGPACK_BUILD_TESTS=OFF
          ..

    make -j$number_of_processes

    make install

    check_all_libraries  $install_prefix/lib

    check_success MessagePack $checkfile
    check=$?
fi

cd $SIMPATH

return 1
