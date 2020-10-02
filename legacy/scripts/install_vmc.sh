#!/bin/bash

if [ ! -d  $SIMPATH/transport/vmc ];
then
  cd $SIMPATH/transport
  if [ ! -e v$VMCVERSION.tar.gz ];
  then
    echo "*** Downloading VMC sources ***"
    download_file $VMC_LOCATION/v$VMCVERSION.tar.gz
  fi
  untar vmc-$VMCVERSION v$VMCVERSION.tar.gz
  if [ -d vmc-$VMCVERSION ];
  then
    ln -s vmc-$VMCVERSION vmc
  fi
fi

install_prefix=$SIMPATH_INSTALL
checkfile=$install_prefix/lib/libVMCLibrary.so

if [ ! -d $install_prefix/lib ];
then
  mkdir -p $install_prefix/lib
fi

if (not_there vmc $checkfile)
then

  cd $SIMPATH/transport/vmc

  mypatch ../dict_fixes_101.patch

  if (not_there vmc-build build);
  then
      mkdir build
  fi
  cd build

  cmake -DCMAKE_INSTALL_PREFIX=$install_prefix ..

  $MAKE_command -j$number_of_processes install

  if [ "$platform" = "macosx" ];
  then
    cd $install_prefix/lib
    create_links dylib so
  fi

  check_all_libraries $install_prefix/lib

  check_success vmc $checkfile
  check=$?
fi

if [ "$platform" = "macosx" ];
then
  export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$install_prefix/lib
else
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$install_prefix/lib
fi

cd $SIMPATH

return 1
