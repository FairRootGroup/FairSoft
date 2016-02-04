#!/bin/bash

if [ ! -d  $SIMPATH/basics/flatbuffers ];
then
  cd $SIMPATH/basics
  echo "*** Downloading FlatBuffers sources ***"
  git clone $FLATBUFFERS_LOCATION
  cd $SIMPATH/basics/flatbuffers
  git checkout -b $FLATBUFFERS_BRANCH $FLATBUFFERS_BRANCH
fi

install_prefix=$SIMPATH_INSTALL
checkfile=$install_prefix/bin/flatc

if (not_there FlatBuffers $checkfile);
then
    cd $SIMPATH/basics/flatbuffers

    cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$install_prefix

    make -j$number_of_processes

    make install

    check_all_libraries  $install_prefix/lib

    check_success FlatBuffers $checkfile
    check=$?
fi

cd $SIMPATH

return 1
