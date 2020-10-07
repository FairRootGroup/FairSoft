#!/bin/bash

cd $SIMPATH/basics

if [ ! -d  $SIMPATH/basics/FairMQ ];
then
  git clone $FAIRMQ_LOCATION
fi

checkfile=$SIMPATH_INSTALL/bin/fairmq-bsampler

if (not_there FairMQ $checkfile);
then
  cd FairMQ
  git checkout $FAIRMQ_VERSION

#  mypatch ../fairmq_fix_cpp17moveinsertable_assertion_xcode12.patch

  if [ ! -d  build ];
  then
    mkdir build
  fi
  cd build
  cmake -DCMAKE_INSTALL_PREFIX=$SIMPATH_INSTALL \
        -DCMAKE_PREFIX_PATH=$SIMPATH_INSTALL \
        -DBUILD_TESTING=OFF \
        -DBUILD_NANOMSG_TRANSPORT=ON \
        -DBUILD_DDS_PLUGIN=ON \
        -DBUILD_SDK_COMMANDS=ON \
        ..
  $MAKE_command -j$number_of_processes install
fi
check_success FairMQ $checkfile
check=$?

cd $SIMPATH
return 1
