#!/bin/bash

if [ ! -d  $SIMPATH/basics/yaml-cpp ]; then
  cd $SIMPATH/basics
  git clone $YAMLCPP_LOCATION

  cd $SIMPATH/basics/yaml-cpp
  git checkout -b tag_$YAMLCPP_VERSION yaml-cpp-$YAMLCPP_VERSION
fi

install_prefix=$SIMPATH_INSTALL

checkfile=$install_prefix/include/yaml-cpp/anchor.h

if (not_there Yaml-Cpp $checkfile);
then
    cd $SIMPATH/basics/yaml-cpp
    mkdir build
    cd build
    cmake -DCMAKE_C_COMPILER=$CC         \
          -DCMAKE_CXX_COMPILER=$CXX      \
          -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
          -DCMAKE_INSTALL_PREFIX=$SIMPATH_INSTALL \
          -DYAML_CPP_BUILD_TESTS=OFF \
          -DBUILD_SHARED_LIBS=ON         \
          ..

    make -j$number_of_processes
    make install

    check_all_libraries $install_prefix/lib

    check_success Yaml-Cpp $checkfile
    check=$?

fi

cd $SIMPATH

return 1
