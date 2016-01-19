#!/bin/bash

if [ ! -d  $SIMPATH/basics/zeromq ];
then
  cd $SIMPATH/basics
  if [ ! -e zeromq-$ZEROMQVERSION.tar.gz ];
  then
    echo "*** Downloading zeromq sources ***"
    download_file $ZEROMQ_LOCATION/zeromq-$ZEROMQVERSION.tar.gz
  fi
  untar zeromq zeromq-$ZEROMQVERSION.tar.gz
  if [ -d zeromq-$ZEROMQDIR ];
  then
    ln -s zeromq-$ZEROMQDIR zeromq
  fi
fi

install_prefix=$SIMPATH_INSTALL
checkfile=$install_prefix/lib/libzmq.a

if (not_there zeromq $checkfile);
then
    cd $SIMPATH/basics/zeromq

#    mypatch ../zeromq_clang_c++11.patch

    distribution=$(lsb_release -is)
    version=$(lsb_release -rs | cut -f1 -d.)     

    if [ "$arch" == "ppc64le" ];then
     ./autogen.sh
    fi

    if [ "$distribution$version" = "ScientificCERNSLC6" ]; then
      PKG_CONFIG_PATH=$SIMPATH_INSTALL/lib/pkgconfig ./configure --prefix=$install_prefix --libdir=$install_prefix/lib --enable-static --without-libsodium
    else
      PKG_CONFIG_PATH=$SIMPATH_INSTALL/lib/pkgconfig ./configure --prefix=$install_prefix --libdir=$install_prefix/lib --enable-static
    fi
    
    make
    make install

    check_all_libraries  $install_prefix/lib

    check_success zeromq $checkfile
    check=$?


    if [ "$platform" = "macosx" ];
    then
      cd $install_prefix/lib
      create_links dylib so
    fi
fi

#cp $SIMPATH/basics/zmq.hpp  $install_prefix/include/zmq.hpp
cd $SIMPATH

return 1
