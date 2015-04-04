#!/bin/bash

#author: Ahmed El Alaoui, USM

# Check if the source tar file is already available 
# If not download it a from the lhapdf web server and unpack it

soft="lhapdf-${LHAPDF_VERSION}"
echo "*** DEBUG $soft sources ***"
if [ ! -d  $SIMPATH/tools/$soft ]; then 
  cd $SIMPATH/tools
  if [ ! -e $SIMPATH/tools/$LHAPDF_TAR ]; then
    echo "*** Downloading $soft sources ***"
    cd $SIMPATH/tools; download_file $LHAPDF_LOCATION/$LHAPDF_TAR;cd -
  fi
  untar $soft $SIMPATH/tools/$LHAPDF_TAR
fi

install_prefix=$SIMPATH_INSTALL
checkfile=$install_prefix/lib/libLHAPDF.so


if (not_there $soft $checkfile); then

  mkdir $SIMPATH/build_soft/build_$soft
  cd $SIMPATH/build_soft/build_$soft

  debug_=""
  if [ "$debug" = "yes" ]; then
    debug_="--enable-debug"
  fi

  $SIMPATH/tools/$soft/configure --prefix=$install_prefix \
                --srcdir=$SIMPATH/tools/$soft $debug_
  $MAKE_command 
  $MAKE_command install 2>&1 | tee make_install_${soft}.log

  check_all_libraries $install_prefix/lib
  check_success $soft $checkfile
  check=$?

fi

cd  $SIMPATH
return 1
