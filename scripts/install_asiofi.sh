#!/bin/bash

cd $SIMPATH/basics

if [ ! -d  $SIMPATH/basics/asiofi ];
then
  git clone $ASIOFI_LOCATION
fi

checkfile=$SIMPATH_INSTALL/include/asiofi/version.hpp

if (not_there asiofi $checkfile);
then
  cd asiofi
  git checkout $ASIOFI_VERSION
  if [ ! -d  build ];
  then
    mkdir build
  fi
  cd build
  cmake -DCMAKE_INSTALL_PREFIX=$SIMPATH_INSTALL \
        -DCMAKE_PREFIX_PATH=$SIMPATH_INSTALL \
        ..
  cmake --build . --target install -- -j$number_of_processes
fi
check_success asiofi $checkfile
check=$?

cd $SIMPATH
return 1
