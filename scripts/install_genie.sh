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
# modify path to ROOT
  echo "*** modify path to root ***"
  mysed "lib\/libMathMore.so" "lib\/root\/libMathMore.so" $SIMPATH/generators/$soft/configure
  mysed "check-previous-installation" "# check-previous-installation" $SIMPATH/generators/$soft/Makefile
# modify compiler option
  if [ $hascxx11 ]; then
    echo "*** Configure GENIE with c++11 ***"
    mysed "GOPT_WITH_CXX_USERDEF_FLAGS=" "GOPT_WITH_CXX_USERDEF_FLAGS=-std=c++11" $SIMPATH/generators/$soft/src/make/Make.include
  fi 
# fix errors in gtestINukeHadroXSec, gVldSampleScan
  mysed "ifstream test_file;" "std::ifstream test_file;" $SIMPATH/generators/$soft/src/validation/Intranuke/gtestINukeHadroXSec.cxx
  mysed "ofstream xsec_file;" "std::ofstream xsec_file;" $SIMPATH/generators/$soft/src/validation/Intranuke/gtestINukeHadroXSec.cxx
  mysed "ofstream" "std::ofstream" $SIMPATH/generators/$soft/src/validation/EvScan/gVldSampleScan.cxx
  if [ -d  $soft ]; then
    ln -s $soft genie
  fi
fi 

install_prefix=$SIMPATH_INSTALL
checkfile=$install_prefix/lib/libGNuGamma-${GENIE_VERSION}.so

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
  # make command does not work, do it by hand
  cp $SIMPATH/generators/$soft/lib/* $install_prefix/lib
  cp $SIMPATH/generators/$soft/bin/* $install_prefix/bin

  check_all_libraries $install_prefix/lib
  check_success $soft $checkfile
  check=$?
fi
if [ ! -d  $SIMPATH_INSTALL/share/lhapdf/data ]; then
 mkdir $SIMPATH_INSTALL/share/lhapdf/data
fi
cp $SIMPATH/generators/$soft/data/evgen/pdfs/GRV98lo_patched.LHgrid $SIMPATH_INSTALL/share/lhapdf/data/

if [ ! -d  $SIMPATH_INSTALL/share/genie ]; then
 mkdir $SIMPATH_INSTALL/share/genie
fi
cp -r $SIMPATH/generators/$soft/data $SIMPATH_INSTALL/share/genie
if [ -f $SIMPATH/generators/$soft/src/Algorithm/_ROOT_DICT_Algorithm_rdict.pcm ]; then
 cp $SIMPATH/generators/$soft/src/*/*.pcm $SIMPATH_INSTALL/lib/
fi
cd  $SIMPATH
return 1
