#!/bin/bash

cd $SIMPATH/basics

if [ ! -d  $SIMPATH/basics/zeromq ];
then
  git clone $ZEROMQ_LOCATION zeromq
fi

install_prefix=$SIMPATH_INSTALL
checkfile=$install_prefix/lib/libzmq.a

if (not_there zeromq $checkfile);
then
  cd zeromq
  git checkout $ZEROMQ_VERSION
  if [ ! -d  build ];
  then
    mkdir build
  fi
  cd build

  cmake .. \
        -DWITH_PERF_TOOL=ON \
        -DZMQ_BUILD_TESTS=ON \
        -DENABLE_CPACK=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$install_prefix
  $MAKE_command -j$number_of_processes install
  ctest

  check_all_libraries  $install_prefix/lib

  check_success zeromq $checkfile
  check=$?

  if [ "$platform" = "macosx" ];
  then
    cd $install_prefix/lib
    create_links dylib so
  fi
fi

cd $SIMPATH

return 1
