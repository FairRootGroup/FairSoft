#!/bin/bash
#export CXXVERBOSE=1


if [ ! -d  $SIMPATH/transport/geant3 ]; then
  cd $SIMPATH/transport
  git clone $GEANT3_LOCATION

  cd $SIMPATH/transport/geant3
  git checkout -b $GEANT3BRANCH $GEANT3BRANCH

fi

install_prefix=$SIMPATH_INSTALL
checkfile=$install_prefix/lib/libgeant321.so

if (not_there Geant3 $checkfile);
then

  mkdir -p $install_prefix/include/TGeant3

  cd $SIMPATH/transport/geant3

# ????
#  if [ "$build_root6" = "yes" ]; then
#    mypatch ../geant3_root6.patch
#  fi

  mkdir build
  cd build
  cmake -DCMAKE_INSTALL_PREFIX=$SIMPATH_INSTALL \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
        -DCMAKE_CXX_COMPILER=$CXX \
        -DCMAKE_C_COMPILER=$CC \
        -DROOT_DIR=$SIMPATH_INSTALL \
        ..

  make install -j$number_of_processes

  if [ "$platform" = "macosx" ];
  then
    cd $install_prefix/lib
    for file in $(ls libgeant321.dylib); do
       install_name_tool -id $install_prefix/lib/$file $file
    done
    create_links dylib so
  fi

  check_all_libraries $install_prefix/lib

  check_success Geant3 $checkfile
  check=$?

fi

if [ "$platform" = "macosx" ];
then
  export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$install_prefix
else
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SIMPATH/install_prefix
fi

cd $SIMPATH

return 1
