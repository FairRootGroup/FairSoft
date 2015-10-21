#!/bin/bash

#author: Ahmed El Alaoui, USM

# Check if the source tar file is already available 
# If not download it a from the lhapdf web server and unpack it

soft="lhapdf-${LHAPDF_VERSION}"
echo "*** Install $soft sources in $SIMPATH and copy to $SIMPATH_INSTALL ***"
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
  mkdir $SIMPATH/tools/build_$soft
  cd $SIMPATH/tools/build_$soft

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

# temporary hack, since I don't understand what is going wrong
checkfile=$install_prefix/bin/lhapdf-getdata
if (not_there $soft $checkfile); then
  cp $SIMPATH/tools/$soft/bin/lhapdf-getdata $install_prefix/bin/
  cp $SIMPATH/tools/$soft/bin/lhapdf-query $install_prefix/bin/
fi

return 1
