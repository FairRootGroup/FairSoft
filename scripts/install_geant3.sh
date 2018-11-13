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

#  echo "Switching off optimization when compiling Geant3. Optimization introduces some errors with newer gfortran versions." | tee -a $logfile
#  CXXFLAGS_BAK=$CXXFLAGS
#  CFLAGS_BAK=$CFLAGS
#  FFLAGS_BAK=$FFLAGS
#  export CXXFLAGS="-g -O0"
#  export CFLAGS="-g -O0"
#  export FFLAGS="-g -O0"

  mkdir -p $install_prefix/include/TGeant3

  cd $SIMPATH/transport
  cp gdecay.F geant3/gphys
  cp gdalet.F geant3/gphys
  cp gdalitzcbm.F geant3/gphys

  cd geant3
  # add support for gcalor. Remove files with dummy functions which are implemented in gcalor.F
  mkdir gcalor
  cp ../gcalor.F gcalor
  rm added/dummies_gcalor.c

  # patches needed to compile gcalor and for changes in geane
  mypatch ../geant3_geane.patch | tee -a $logfile
  mypatch ../Geant3_CMake.patch | tee -a $logfile

  mypatch ../geant3_structs.patch | tee -a $logfile

  if [ ! -f data/xsneut.dat ];
  then
    cp ../xsneut.dat.bz2 data
    bunzip2 data/xsneut.dat.bz2
  fi
  cp ../chetc.dat data

  if [ "$build_root6" = "yes" ]; then
    mypatch ../geant3_root6.patch
  fi  

  mypatch ../geant3_gfortran.patch | tee -a $logfile
  
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

#  export CXXFLAGS=$CXXFLAGS_BAK
#  export CFLAGS=$CFLAGS_BAK
#  export FFLAGS=$FFLAGS_BAK

fi

if [ "$platform" = "macosx" ];
then
  export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$install_prefix
else
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SIMPATH/install_prefix
fi

cd $SIMPATH

return 1
