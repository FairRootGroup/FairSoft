#!/bin/bash


if [ ! -d  $SIMPATH/transport/geant4_vmc ]; then
  cd $SIMPATH/transport
  git clone $GEANT4VMC_LOCATION

  cd $SIMPATH/transport/geant4_vmc
  git checkout -b $GEANT4VMCBRANCH $GEANT4VMCBRANCH
fi

install_prefix=$SIMPATH_INSTALL
checkfile=$install_prefix/lib/libgeant4vmc.so

if (not_there Geant4_VMC $checkfile);
then

  cd $SIMPATH/transport/geant4_vmc

  mkdir build
  cd build
  cmake -DCMAKE_INSTALL_PREFIX=$SIMPATH_INSTALL \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
        -DCMAKE_CXX_COMPILER=$CXX \
        -DCMAKE_C_COMPILER=$CC \
        -DGeant4VMC_USE_VGM=ON \
        -DGeant4VMC_USE_GEANT4_UI=Off \
        -DGeant4VMC_USE_GEANT4_VIS=Off \
        -DGeant4VMC_USE_GEANT4_G3TOG4=On \
        -DGeant4_DIR=$SIMPATH_INSTALL \
        -DROOT_DIR=$SIMPATH_INSTALL \
        -DVGM_DIR=$SIMPATH_INSTALL/lib/$VGMDIR \
        ..

  make install -j$number_of_processes

  if [ "$platform" = "macosx" ];
  then
    cd $install_prefix/lib
    for file in $(ls libvmc_*.dylib libgeant4_*.dylib libgeant4vmc.dylib libg4root.dylib libmtroot.dylib); do
      install_name_tool -id $install_prefix/lib/$file $file
      for file1 in $(ls libvmc_*.dylib libgeant4_*.dylib libgeant4vmc.dylib libg4root.dylib libmtroot.dylib); do
        install_name_tool -change $file1 $install_prefix/lib/$file1 $file
      done
    done
    create_links dylib so
  fi


  check_success Geant4_VMC $checkfile
  check=$?

  check_all_libraries $install_prefix/lib

  cd $SIMPATH_INSTALL
  mkdir -p share/geant4_vmc
  ln -s $SIMPATH_INSTALL/share/Geant4VMC-3.6.0/examples/macro $SIMPATH_INSTALL/share/geant4_vmc/macro
fi

if [ "$platform" = "macosx" ];
then
  export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$SIMPATH/transport/geant4_vmc/lib/
else
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SIMPATH/transport/geant4_vmc/lib/
fi

cd $SIMPATH

return 1
