#!/bin/bash

distribution=$(lsb_release -is)
version=$(lsb_release -rs | cut -f1 -d.)

if [ "$distribution$version" = "ScientificCERNSLC6" ]; then
  return 1
fi

if [ ! -d  $SIMPATH/basics/libsodium ]; then
  cd $SIMPATH/basics
  git clone $SODIUM_LOCATION

  cd $SIMPATH/basics/libsodium
  git checkout -b $SODIUMBRANCH $SODIUMBRANCH
fi

install_prefix=$SIMPATH_INSTALL
checkfile=$install_prefix/lib/libsodium.a

if (not_there LibSodium $checkfile);
then

  cd $SIMPATH/basics/libsodium

  mkdir build
  
  autoreconf -i
 
  cd build
  
  ../configure --prefix=$install_prefix

  make install -j$number_of_processes

  check_success LibSodium $checkfile
  check=$?

  check_all_libraries $install_prefix/lib

fi

if [ "$platform" = "macosx" ];
then
  export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$SIMPATH/transport/geant4_vmc/lib/
else
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SIMPATH/transport/geant4_vmc/lib/
fi

cd $SIMPATH

return 1
