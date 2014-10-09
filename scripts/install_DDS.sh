#!/bin/bash


if [ ! -d  $SIMPATH/DDS ];
then
  cd $SIMPATH
  git clone $DDS_LOCATION
fi

install_prefix=$SIMPATH_INSTALL/DDS

 checkfile=$install_prefix/bin/dds-server

if (not_there DDS $checkfile);
then
  cd DDS
  git checkout $DDSVERSION
  if [ ! -d  build_for_alfa ];
  then
    mkdir build_for_alfa
  fi
  cd build_for_alfa
  BOOST_ROOT=$SIMPATH_INSTALL cmake -DCMAKE_INSTALL_PREFIX=install_prefix  -C ../BuildSetup.cmake ../
  $MAKE_command -j$number_of_processes wn_bin
  $MAKE_command -j$number_of_processes install

fi

cd $SIMPATH
return 1
