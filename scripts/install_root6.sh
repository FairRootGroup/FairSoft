#!/bin/bash

# check if the root source directory is already available
# If it is not there get the source tar file from the
# root web server and unpack it

if [ "$build_cpp11" = "yes" ];
then
  CXXFLAGS_BAK=$CXXFLAGS
  CXXFLAGS="$CFLAGS"
  export CXXFLAGS
fi

if [ ! -d  $SIMPATH/tools/root ];
then
  cd $SIMPATH/tools
  # git clone --shallow-since=2017-09-25 --branch $ROOTVERSION $ROOT_LOCATION
  # older git versions dont support --shallow-since, but --depth 1000 will most probably work for the lifetime the root patch branch with almost same repo size
  git clone --depth=10 --branch $ROOTVERSION $ROOT_LOCATION
fi

install_prefix=$SIMPATH_INSTALL
libdir=$install_prefix/lib/root6

checkfile=$install_prefix/bin/root.exe

if [ "$platform" = "macosx" ];
then
  export DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}
else
  export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
fi

if (not_there root $checkfile);
then
  cd $SIMPATH/tools/root
  mkdir build_for_fair

  if [ "$debug" = "yes" ];
  then
    echo "*** Building ROOT with debug information"  | tee -a $logfile
    export ROOTBUILD=debug
  fi

  if [ "$build_for_grid" = "yes" ]
  then
    cp ../rootconfig_grid.sh  build_for_fair/rootconfig.sh
    echo "Copied rootconfig_grid.sh ......................" | tee -a $logfile
  else
    cp ../rootconfig.sh  build_for_fair/
    echo "Copied rootconfig.sh ......................" | tee -a $logfile
  fi
  echo "Configure Root .........................................." | tee -a $logfile

  cd build_for_fair/
  . rootconfig.sh

  $MAKE_command -j$number_of_processes install

  check_all_libraries $install_prefix/lib

  check_success root $checkfile
  check=$?

   ####Work sround for VC snd AliRoot ###
   echo " create a symbolic linking for  Vc library .... "
   if [ -e $install_prefix/lib/libVc.a ];
   then
     cd $install_prefix/lib/root
     ln -s ../libVc.a
     echo "---link created --- "
   else
     echo "libVc.a not found in lib dirctory "
   fi
   #####################################



  export PATH=${install_prefix}/bin:${PATH}

  if [ "$platform" = "macosx" ];
  then
    export DYLD_LIBRARY_PATH=${libdir}:${DYLD_LIBRARY_PATH}
  else
    export LD_LIBRARY_PATH=${libdir}:${LD_LIBRARY_PATH}
  fi
else
  export PATH=${install_prefix}/bin:${PATH}
  if [ "$platform" = "macosx" ];
  then
    export DYLD_LIBRARY_PATH=${libdir}:${DYLD_LIBRARY_PATH}
  else
    export LD_LIBRARY_PATH=${libdir}:${LD_LIBRARY_PATH}
  fi
fi

if [ "$build_cpp11" = "yes" ];
then
  CXXFLAGS=$CXXFLAGS_BAK
  export CXXFLAGS
fi

cd $SIMPATH

return 1
