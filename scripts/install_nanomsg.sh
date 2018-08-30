#!/bin/bash

cd $SIMPATH/basics

if [ ! -d  $SIMPATH/basics/nanomsg ];
then
  git clone $NANOMSG_LOCATION nanomsg
fi

checkfile=$SIMPATH_INSTALL/bin/nanocat

if (not_there nanomsg $checkfile);
then
  cd nanomsg
  git checkout $NANOMSG_VERSION
  if [ ! -d  build ];
  then
    mkdir build
  fi
  cd build
  cmake -DCMAKE_INSTALL_PREFIX=$install_prefix \
        -DCMAKE_PREFIX_PATH=$SIMPATH_INSTALL \
        -DNN_ENABLE_DOC=OFF \
        ..
  cmake --build . --target install -- -j$number_of_processes
fi
check_success nanomsg $checkfile
check=$?

cd $SIMPATH
return 1
