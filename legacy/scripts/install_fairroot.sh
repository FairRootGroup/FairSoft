#!/bin/bash

if [ ! -d  $SIMPATH/FairRoot ];
then
  cd $SIMPATH
  git clone $FAIRROOT_LOCATION
fi

install_prefix=$SIMPATH_INSTALL/FairRoot

checkfile=$install_prefix/lib/libBase.so

if (not_there FairRoot $checkfile);
then
  cd FairRoot
  git checkout $FAIRROOTVERSION
  if [ ! -d  build_for_alfa ];
  then
    mkdir build_for_alfa
  fi
  cd build_for_alfa
  if [ "$onlyreco" = "0" ];
  then
    SIMPATH=$SIMPATH_INSTALL cmake -DCMAKE_INSTALL_PREFIX=$install_prefix ../
  else
    SIMPATH=$SIMPATH_INSTALL cmake -DCMAKE_INSTALL_PREFIX=$install_prefix -DRECO_ONLY=1  ../
  fi
  $MAKE_command -j$number_of_processes
  $MAKE_command  install

fi
cd $SIMPATH
return 1
