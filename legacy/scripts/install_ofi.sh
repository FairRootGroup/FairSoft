#!/bin/bash

cd $SIMPATH/basics

if [ ! -d  $SIMPATH/basics/libfabric ];
then
  git clone $OFI_LOCATION
fi

if [ ! -d  $SIMPATH/basics/fabtests ];
then
  git clone $OFI_TESTS_LOCATION
fi

checkfile=$SIMPATH_INSTALL/bin/fi_info

if (not_there OFI $checkfile);
then
  cd libfabric
  git checkout $OFI_VERSION
  ./autogen.sh
  ./configure --prefix=$SIMPATH_INSTALL --enable-sockets
  $MAKE_command -j$number_of_processes install

  cd ../fabtests
  git checkout $OFI_VERSION
  ./autogen.sh
  ./configure --prefix=$SIMPATH_INSTALL --with-libfabric=$SIMPATH_INSTALL
  $MAKE_command -j$number_of_processes install
fi
check_success OFI $checkfile
check=$?

cd $SIMPATH
return 1
