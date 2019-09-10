#!/bin/bash

if [ ! -d  $SIMPATH/transport/vgm ];
then
  cd $SIMPATH/transport
  if [ ! -d vgm ];
  then
    git clone $VGM_LOCATION
    cd $SIMPATH/transport/vgm
    git checkout $VGMVERSION
  fi
fi


install_prefix=$SIMPATH_INSTALL
checkfile=$install_prefix/lib/libBaseVGM.so

if (not_there VGM $checkfile);
then
  cd $SIMPATH/transport/vgm

  mkdir build_cmake
  cd build_cmake

  # the Geant4_DIR points to the directory where the Geant4Config.cmake script is
  # located. In this file all needed variables are defined.
  cmake -DCMAKE_INSTALL_PREFIX=$install_prefix \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
        -DCMAKE_CXX_COMPILER=$CXX \
        -DCMAKE_C_COMPILER=$CC \
        -DGeant4_DIR=$SIMPATH_INSTALL/lib/$GEANT4VERSIONp \
        -DROOT_DIR=$SIMPATH_INSTALL \
        -DWITH_TEST=OFF \
        ..

  make install -j$number_of_processes

  if [ "$platform" = "macosx" ];
  then
      cd $install_prefix/lib
      for file in $(ls lib*GM.dylib); do
        install_name_tool -id $install_prefix/lib/$file $file
        for file1 in $(ls lib*GM.dylib); do
          install_name_tool -change $file1 $install_prefix/lib/$file1 $file
        done
      done
      create_links dylib so
  fi

  check_success VGM $checkfile
  check=$?

  check_all_libraries $install_prefix/lib

fi

if [ "$platform" = "macosx" ];
then
  export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$install_prefix/lib
else
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$install_prefix/lib
fi

export USE_VGM=1
export VGM_INSTALL=$install_prefix

cd $SIMPATH

return 1
