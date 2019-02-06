#!/bin/bash

install_prefix=$SIMPATH_INSTALL

checkfile=$install_prefix/lib/g4py/__init__.pyc

if (not_there g4py $checkfile);
then

    cd $SIMPATH/transport/geant4/environments/g4py
    mypatch ../../../g4py.patch

    if [ -f ${SIMPATH_INSTALL}/lib/libboost_python27.so ]
      then
        echo "*** Create a symbolic link for libboost_python27.so"
        ln -s ${SIMPATH_INSTALL}/lib/libboost_python27.so ${SIMPATH_INSTALL}/lib/libboost_python.so
    fi

    cd $SIMPATH/transport/geant4
    mkdir build_g4py
    cd build_g4py

    cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
          -DCMAKE_INSTALL_PREFIX=${SIMPATH_INSTALL} \
          -DXERCESC_ROOT_DIR=${SIMPATH_INSTALL} \
          -DBOOST_ROOT=${SIMPATH_INSTALL} \
          -DBoost_NO_SYSTEM_PATHS=TRUE \
          -DBoost_NO_BOOST_CMAKE=TRUE \
          ../environments/g4py

    $MAKE_command -j$number_of_processes
    $MAKE_command install -j$number_of_processes

    if [ "$platform" = "macosx" ];
    then
      cd  $install_prefix/lib
      create_links dylib so
    fi

    check_all_libraries  $install_prefix/lib

    check_success g4py $checkfile
    check=$?

fi

cd $SIMPATH

return 1
