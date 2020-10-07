#!/bin/bash

cd $SIMPATH/basics

if [ ! -d $SIMPATH/basics/DDS ];
then
  git clone $DDS_LOCATION
fi

checkfile=$SIMPATH_INSTALL/bin/dds-session

if (not_there DDS $checkfile);
then
  cd DDS
  git checkout $DDSVERSION

  mypatch ../fix_wn_bin_3.2_3.4.patch

  if [ ! -d  build ];
  then
    mkdir build
  fi
  cd build
  cmake -DCMAKE_INSTALL_PREFIX=$SIMPATH_INSTALL \
      -DCMAKE_CXX_STANDARD=11 \
      -DBoost_NO_BOOST_CMAKE=ON \
      ../
  $MAKE_command -j$number_of_processes
  $MAKE_command -j$number_of_processes wn_bin
  $MAKE_command -j$number_of_processes install
fi

check_success DDS $checkfile
check=$?

cd $SIMPATH
return 1
