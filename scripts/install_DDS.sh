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
  if [ ! -d  build ];
  then
    mkdir build
  fi
  cd build
  BOOST_ROOT=$SIMPATH_INSTALL cmake -DCMAKE_INSTALL_PREFIX=$SIMPATH_INSTALL -C ../BuildSetup.cmake ../
  $MAKE_command -j$number_of_processes wn_bin
  $MAKE_command -j$number_of_processes install
fi

check_success DDS $checkfile
check=$?

cd $SIMPATH
return 1
