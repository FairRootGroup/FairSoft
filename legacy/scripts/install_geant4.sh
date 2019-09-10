#!/bin/bash

# Check if the source tar file is already available
# If not download it a from the geant4 web server and
# unpack it


if [ ! -d  $SIMPATH/transport/geant4 ];
then
  cd $SIMPATH/transport
  git clone $GEANT4_LOCATION

  cd geant4
  git checkout $GEANT4VERSION
fi

# Full output during compilation and linking to check for the
# compile and link commands
#export CPPVERBOSE=1

install_prefix=$SIMPATH_INSTALL
clhep_exe=$SIMPATH_INSTALL/bin/clhep-config

checkfile=$install_prefix/lib/libG4physicslists.so

if (not_there Geant4-lib $checkfile);
then

  cd $SIMPATH/transport/geant4/

  if (not_there Geant4-build  build);
  then
    mkdir build
  fi
  cd build

  if [ "$geant4_download_install_data_automatic" = "yes" ];
  then
    install_data="-DGEANT4_INSTALL_DATA=ON"
  else
    install_data=""
  fi

  if [ "$build_cpp11" = "yes" ];
  then
    geant4_cpp="-DGEANT4_BUILD_CXXSTD=c++11"
  else
    geant4_cpp=""
  fi

  if [ "$build_python" = "yes" ];
  then
    geant4_opengl="-DGEANT4_USE_OPENGL_X11=ON -DGEANT4_USE_GDML=ON -DXERCESC_ROOT_DIR=$install_prefix"
  else
    geant4_opengl=""
  fi

  if [ "$geant4mt" = "yes" ];
  then
    g4mt="-DGEANT4_BUILD_MULTITHREADED=ON"
  else
    g4mt="-DGEANT4_BUILD_MULTITHREADED=OFF"
  fi

  cmake -DCMAKE_INSTALL_PREFIX=$install_prefix \
        -DCMAKE_INSTALL_LIBDIR=$install_prefix/lib \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
        -DCMAKE_CXX_COMPILER=$CXX \
        -DCMAKE_C_COMPILER=$CC \
        -DGEANT4_USE_G3TOG4=ON \
        -DGEANT4_BUILD_STORE_TRAJECTORY=OFF \
        -DGEANT4_BUILD_VERBOSE_CODE=ON \
        -DGEANT4_BUILD_TLS_MODEL="global-dynamic" \
        $geant4_opengl $g4mt\
        $install_data  $geant4_cpp ../

  $MAKE_command -j$number_of_processes  install

  # copy the env.sh script to the bin directorry
  mkdir -p $install_prefix/bin
 # cp $G4WORKDIR/env.sh $install_prefix/bin

  if [ "$platform" = "macosx" ];
  then
    cd $install_prefix/lib
    create_links dylib so
  fi

  if [ "$geant4_download_install_data_automatic" = "yes" ];
  then
    # create unique links which is independent of the Geant4 version
    if [ ! -L $install_prefix/share/Geant4 ]; then
      ln -s $install_prefix/share/$GEANT4VERSIONp $install_prefix/share/Geant4
    fi
    # create unique links for the data directories which are
    # independent of the actual data versions
    if [ ! -L $install_prefix/share/Geant4/data/G4ABLA ]; then
      ln -s $install_prefix/share/Geant4/data/${G4ABLA_VERSION} $install_prefix/share/Geant4/data/G4ABLA
    fi
    if [ ! -L $install_prefix/share/Geant4/data/G4EMLOW ]; then
      ln -s $install_prefix/share/Geant4/data/${G4EMLOW_VERSION} $install_prefix/share/Geant4/data/G4EMLOW
    fi
    if [ ! -L $install_prefix/share/Geant4/data/G4ENSDFSTATE ]; then
      ln -s $install_prefix/share/Geant4/data/${G4ENSDFSTATE_VERSION} $install_prefix/share/Geant4/data/G4ENSDFSTATE
    fi
    if [ ! -L $install_prefix/share/Geant4/data/G4NDL ]; then
      ln -s $install_prefix/share/Geant4/data/${G4NDL_VERSION} $install_prefix/share/Geant4/data/G4NDL
    fi
    if [ ! -L $install_prefix/share/Geant4/data/G4PARTICLEXS ]; then
      ln -s $install_prefix/share/Geant4/data/${G4PARTICLEXS_VERSION} $install_prefix/share/Geant4/data/G4PARTICLEXS
    fi
    if [ ! -L $install_prefix/share/Geant4/data/G4PII ]; then
      ln -s $install_prefix/share/Geant4/data/${G4PII_VERSION} $install_prefix/share/Geant4/data/G4PII
    fi
    if [ ! -L $install_prefix/share/Geant4/data/G4SAIDDATA ]; then
      ln -s $install_prefix/share/Geant4/data/${G4SAIDDATA_VERSION} $install_prefix/share/Geant4/data/G4SAIDDATA
    fi
    if [ ! -L $install_prefix/share/Geant4/data/PhotonEvaporation ]; then
      ln -s $install_prefix/share/Geant4/data/${PhotonEvaporation_VERSION} $install_prefix/share/Geant4/data/PhotonEvaporation
    fi
    if [ ! -L $install_prefix/share/Geant4/data/RadioactiveDecay ]; then
      ln -s $install_prefix/share/Geant4/data/${RadioactiveDecay_VERSION} $install_prefix/share/Geant4/data/RadioactiveDecay
    fi
    if [ ! -L $install_prefix/share/Geant4/data/RealSurface ]; then
      ln -s $install_prefix/share/Geant4/data/${RealSurface_VERSION} $install_prefix/share/Geant4/data/RealSurface
    fi
    if [ ! -L $install_prefix/share/Geant4/data/G4INCL ]; then
      ln -s $install_prefix/share/Geant4/data/${G4INCL_VERSION} $install_prefix/share/Geant4/data/G4INCL
    fi

  fi

  . $install_prefix/share/$GEANT4VERSIONp/geant4make/geant4make.sh

  check_success geant4 $checkfile
  check=$?

else

  . $install_prefix/share/$GEANT4VERSIONp/geant4make/geant4make.sh

fi

cd  $SIMPATH
return 1
