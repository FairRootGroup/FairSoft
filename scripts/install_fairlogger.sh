#!/bin/bash

if [ ! -d  $SIMPATH/FairLogger ];
then
  cd $SIMPATH
  git clone $FAIRLOGGER_LOCATION
fi

install_prefix=$SIMPATH_INSTALL

checkfile=$install_prefix/bin/loggerTest

if (not_there FairLogger $checkfile);
then
  cd FairLogger
  git checkout $FAIRLOGGER_VERSION
  if [ ! -d  build_for_alfa ];
  then
    mkdir build_for_alfa
  fi
  cd build_for_alfa
  cmake -DCMAKE_INSTALL_PREFIX=$install_prefix ..
  $MAKE_command -j$number_of_processes install
fi

cd $SIMPATH
return 1
