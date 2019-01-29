#!/bin/bash


if [ ! -d  $SIMPATH/basics/gtest ];
then
  cd $SIMPATH/basics
  if [ ! -e $GTESTVERSION.zip ];
  then
    echo "*** Downloading gtest sources ***"
    download_file $GTEST_LOCATION/$GTESTVERSION.tar.gz
  fi
  untar gtest $GTESTVERSION.tar.gz
  if [ -d  googletest-$GTESTVERSION ];
  then
    ln -s googletest-$GTESTVERSION gtest
  fi
fi


install_prefix=$SIMPATH_INSTALL

checkfile=$install_prefix/lib/libgtestd.a

if (not_there gtest $checkfile);
then
    cd $SIMPATH/basics
    cd gtest
    [ -d build ] || mkdir build
    cd build
    cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
          -DCMAKE_CXX_COMPILER=$CXX \
          -DCMAKE_C_COMPILER=$CC \
          -DCMAKE_INSTALL_PREFIX=$install_prefix \
          ..
    make install

    check_all_libraries  $install_prefix/lib

    check_success gtest $checkfile
    check=$?

fi

cd $SIMPATH

return 1
