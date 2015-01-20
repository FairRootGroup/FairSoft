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
  cmake .. -DCMAKE_INSTALL_PREFIX=$SIMPATH_INSTALL -DGeant4VMC_USE_VGM=ON \
  	-DGeant4VMC_USE_GEANT4_UI=Off -DGeant4VMC_USE_GEANT4_VIS=Off \
  	-DGeant4VMC_USE_GEANT4_G3TOG4=On -DGeant4_DIR=$SIMPATH_INSTALL \
  	-DROOT_DIR==$SIMPATH_INSTALL -DVGM_DIR=$SIMPATH_INSTALL/lib/$VGMDIR

  make -j$number_of_processes
  make install

  if [ "$platform" = "macosx" ];
  then
    cd $install_prefix/lib
    create_links dylib so
  fi


  check_success Geant4_VMC $checkfile
  check=$?

  check_all_libraries $install_prefix/lib

  cd $SIMPATH_INSTALL
  mkdir -p share/geant4_vmc
  ln -s $SIMPATH_INSTALL/share/Geant4VMC-3.1.1/examples/macro $SIMPATH_INSTALL/share/geant4_vmc/macro
fi

if [ "$platform" = "macosx" ];
then
  export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$SIMPATH/transport/geant4_vmc/lib/
else
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SIMPATH/transport/geant4_vmc/lib/
fi

cd $SIMPATH

return 1
