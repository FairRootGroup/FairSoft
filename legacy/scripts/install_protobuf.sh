#!/bin/bash


if [ ! -d  $SIMPATH/basics/protobuf ];
then
  cd $SIMPATH/basics
  if [ ! -e protobuf-cpp-$PROTOBUF_VERSION.tar.gz ];
  then
    echo "*** Downloading protobuf sources ***"
    download_file $PROTOBUF_LOCATION/protobuf-cpp-$PROTOBUF_VERSION.tar.gz
  fi
  untar protobuf protobuf-cpp-$PROTOBUF_VERSION.tar.gz
  if [ -d protobuf-$PROTOBUF_VERSION ];
  then
    ln -s protobuf-$PROTOBUF_VERSION protobuf
  fi
fi

install_prefix=$SIMPATH_INSTALL

checkfile=$install_prefix/bin/protoc

if (not_there protobuf $checkfile);
then
    cd $SIMPATH/basics/protobuf

    if [ $isMacOsx108 ]; then
      export LIBS="-lc++"
    fi

    ./configure --prefix=$install_prefix

    make -j$number_of_processes

    make install

    check_all_libraries  $install_prefix/lib

    check_success protobuf $checkfile
    check=$?

    unset LIBS
fi

cd $SIMPATH

return 1
