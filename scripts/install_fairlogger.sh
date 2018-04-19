#!/bin/bash

cd $SIMPATH/basics

if [ ! -d  $SIMPATH/basics/FairLogger ];
then
  git clone $FAIRLOGGER_LOCATION
fi

checkfile=$SIMPATH_INSTALL/bin/loggerTest

if (not_there FairLogger $checkfile);
then
  cd FairLogger
  git checkout $FAIRLOGGER_VERSION
  if [ ! -d  build ];
  then
    mkdir build
  fi
  cd build
  cmake -DCMAKE_INSTALL_PREFIX=$SIMPATH_INSTALL ..
  $MAKE_command -j$number_of_processes install
fi

check_success FairLogger $checkfile
check=$?


cd $SIMPATH
return 1
