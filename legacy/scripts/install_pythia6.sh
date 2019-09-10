
#!/bin/bash


if [ ! -d  $SIMPATH/generators/pythia6 ];
then
  cd $SIMPATH/generators
  if [ ! -e $PYTHIA6VERSION.tar.gz ];
  then
    echo "*** Downloading pythia6 sources ***"
    download_file $PYTHIA6_LOCATION/$PYTHIA6VERSION.tar.gz
  fi
  untar pythia6 $PYTHIA6VERSION.tar.gz
fi

install_prefix=$SIMPATH_INSTALL

checkfile=$install_prefix/lib/libPythia6.so

if [ ! -d $install_prefix/lib ];
then
  mkdir -p $install_prefix/lib
fi

if (not_there Pythia6 $checkfile);
then

  cd $SIMPATH/generators/pythia6
  cp ../CMakeLists.txt_pythia6 CMakeLists.txt
  mkdir build
  cd build

  cmake -DCMAKE_INSTALL_PREFIX=$install_prefix \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
        -DCMAKE_CXX_COMPILER=$CXX \
        -DCMAKE_C_COMPILER=$CC \
        ..

  make install

  if [ "$platform" = "macosx" ];
  then
      cp libPythia6.dylib $install_prefix/lib
      cd  $install_prefix/lib
      for file in $(ls libPythia6.dylib); do
         install_name_tool -id $install_prefix/lib/$file $file
      done
      create_links dylib so
      if [ ! -e libpythia6.dylib ]; then
        ln -s libPythia6.dylib libpythia6.dylib
      fi
  fi

  if [ ! -e libpythia6.so ]; then
    ln -s libPythia6.so libpythia6.so
  fi

  check_all_libraries $install_prefix/lib

  check_success Pythia6 $checkfile
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
