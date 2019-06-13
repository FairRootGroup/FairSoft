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

checkfile=$install_prefix/lib/libgtest.a

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

    # When using the debug configuration the created library have
    # an additional postfix "d". Create an symbolic link in this case
    # to restore the old library name
    if [ -f $install_prefix/lib/libgtestd.a ]; then
      ln -s $install_prefix/lib/libgtestd.a $install_prefix/lib/libgtest.a
    fi
    if [ -f $install_prefix/lib/libgtest_maind.a ]; then
      ln -s $install_prefix/lib/libgtest_maind.a $install_prefix/lib/libgtest_main.a
    fi

    check_success gtest $checkfile
    check=$?

fi

cd $SIMPATH

return 1
