#!/bin/bash

#author: Ahmed El Alaoui, USM

#
# Check if the source tar file is already available 
# If not download it a from the genie web server and unpack it
# the following packages need to be installed first
# ROOT, PYTHIA6, LHAPDF, log4cpp, libxml2 
#

soft="genie-${GENIE_VERSION}"
if [ ! -d  $SIMPATH/generators/$soft ]; then
  cd $SIMPATH/generators
  if [ ! -e $SIMPATH/tools/$GENIE_TAR ]; then
    echo "*** Downloading $soft sources with subversion***"
    svn checkout $GENIE_LOCATION/$GENIE_BRANCH $soft
  fi
  untar $soft $SIMPATH/tools/$GENIE_TAR
  if [ -d  $soft ]; then
    ln -s $soft genie
  fi
fi 

install_prefix=$SIMPATH_INSTALL
checkfile=$install_prefix/lib/libGNuGamma-2.8.6.so

if (not_there $soft $checkfile); then

  cd $SIMPATH/generators/$soft

  debug_=""
  if [ "$debug" = "yes" ]; then
    debug_="--enable-debug"
  fi

  export GENIE=$SIMPATH/generators/$soft
  source $SIMPATH_INSTALL/bin/thisroot.sh

  ./configure --prefix=$install_prefix $debug_ --enable-lhapdf --enable-validation-tools \
              --enable-test --enable-numi --enable-atmo --enable-nucleon-decay --enable-rwght \
              --with-log4cpp-lib=$SIMPATH_INSTALL/lib \
              --with-log4cpp-inc=$SIMPATH_INSTALL/include \
              --with-lhapdf-lib=$SIMPATH_INSTALL/lib \
              --with-lhapdf-inc=$SIMPATH_INSTALL/include \
              --with-pythia6-lib=$SIMPATH_INSTALL/lib \
              --with-libxml2-lib=/usr/lib64 \
              --with-libxml2-inc=/usr/include/libxml2

  $MAKE_command
  $MAKE_command install

  check_all_libraries $install_prefix/lib
  check_success $soft $checkfile
  check=$?
fi

cd  $SIMPATH
return 1
