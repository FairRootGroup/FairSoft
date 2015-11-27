#!/bin/bash

if [ ! -d  $SIMPATH/AliRoot ];
then
  cd $SIMPATH
  git clone $ALIROOT_LOCATION
fi

install_prefix=$SIMPATH_INSTALL/AliRoot
export GEANT3DIR=$SIMPATH_INSTALL/share/geant3
export ALICE_ROOT=$SIMPATH/AliRoot
export ALICE_TARGET=`root-config --arch`

export ROOTSYS=$SIMPATH_INSTALL
export ZEROMQ=$SIMPATH_INSTALL


checkfile=$install_prefix/lib/libSTEER.so

if (not_there AliRoot $checkfile);
then
  cd AliRoot
  git checkout $ALIROOTVERSION

  if [ ! -d  build_for_alfa ];
  then
    mkdir build_for_alfa
  fi
  cd build_for_alfa

  #cmake -DCMAKE_INSTALL_PREFIX=$install_prefix -DGEANT3DIR=$SIMPATH_INSTALL -DGEANT3_INCLUDE_DIR=$SIMPATH_INSTALL/include/TGeant3  -DGEANT3_LIBRARY_DIR=$SIMPATH_INSTALL/lib  -DGEANT3_SYSTEM_DIR=$SIMPATH_INSTALL/share/geant3 -DZEROMQ_LIBRARY=$SIMPATH_INSTALL/lib -DZEROMQ_INCLUDE_DIR=$SIMPATH_INSTALL/include $ALICE_ROOT -DROOTSYS=$ROOTSYS
  cmake -DCMAKE_INSTALL_PREFIX=$install_prefix -DGEANT3DIR=$SIMPATH_INSTALL -DGEANT3_INCLUDE_DIR=$SIMPATH_INSTALL/include/TGeant3  -DGEANT3_LIBRARY_DIR=$SIMPATH_INSTALL/lib  -DGEANT3_SYSTEM_DIR=$SIMPATH_INSTALL/share/geant3 -DZEROMQ=$SIMPATH_INSTALL $ALICE_ROOT -DROOTSYS=$ROOTSYS

  $MAKE_command -j$number_of_processes
  $MAKE_command  install

fi
cd $SIMPATH
return 1
