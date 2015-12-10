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
  git clone $ROOT_LOCATION

  cd $SIMPATH/tools/root
  git checkout -b $ROOTVERSION $ROOTVERSION
fi

install_prefix=$SIMPATH_INSTALL
libdir=$install_prefix/lib/root

checkfile=$install_prefix/bin/root.exe

if [ "$platform" = "macosx" ];
then
  export DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}
else
  export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
fi

# install xrootd as prerequisit for root
# since we use a script delivered with root we have to first unpack root to use the script
# TODO: Check if the installation was done already
if (not_there xrootd $install_prefix/bin/xrd);
then
  cd $SIMPATH/tools/root
  mypatch ../xrootd_cmake.patch
  build/unix/installXrootd.sh $install_prefix -v $XROOTDVERSION --no-vers-subdir
  if [ "$platform" = "macosx" ];
  then
      cd $install_prefix/lib
      for file in $(ls libXrd*.dylib); do
        install_name_tool -id $install_prefix/lib/$file $file
        for file1 in $(ls libXrd*.dylib); do
          install_name_tool -change  $file1 $install_prefix/lib/$file1 $file
        done
      done
      create_links dylib so
  fi
fi

if (not_there root $checkfile);
then
  cd $SIMPATH/tools/root
  if [ ! -d  build_for_fair ];
  then
   mkdir build_for_fair
  fi

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

  # actualy one should check for mac os x 10.8
  if [ "$platform" = "macosx" -a "$compiler" = "Clang" ];
  then
    mysed 'DEBUGFLAGS    = -g$(DWARF2)' 'DEBUGFLAGS    =' config/Makefile.macosx64
    mysed 'LDFLAGS       = $(OPT) -m64 -mmacosx-version-min=$(MACOSXVERS)' 'LDFLAGS       = -m64 -mmacosx-version-min=$(MACOSXVERS)' config/Makefile.macosx64
  fi

  # needed to compile with Apple LLVM 5.1, shouldn't hurt on other systems
#  mypatch ../root5_34_17_LLVM51.patch | tee -a $logfile
#  mypatch ../root5_34_17_linux_libc++.patch | tee -a $logfile

  # needed to solve problem with the TGeoManger for some CBM and Panda geometries
  mypatch ../root_TGeoShape.patch

  # needed due to some problem with the ALICE HLT code
  mypatch ../root5_34_19_hlt.patch

  # needed to compile root6 with newer versions of xrootd
  if [ "$build_root6" = "yes" ]; then
    mypatch ../root6_xrootd.patch
    mypatch ../root6_00_find_xrootd.patch
  fi

  # add python command history to ROOT.py
  mypatch ../root_pythonhistory.patch

  if [ "$build_root6" = "no" ]; then
    mypatch ../root5_34_find_xrootd.patch
  fi
  cd build_for_fair/
  . rootconfig.sh

  $MAKE_command -j$number_of_processes
  echo "make finished" 
  cd $SIMPATH/tools/root/etc/vmc

  if [ "$arch" = "linuxx8664icc" ];
  then
    cp Makefile.linuxx8664gcc Makefile.linuxx8664icc
    mysed 'g++' 'icpc' Makefile.linuxx8664icc
    mysed 'g77' 'ifort' Makefile.linuxx8664icc
    mysed 'gcc' 'icc' Makefile.linuxx8664icc
    mysed 'SHLIB         = -lg2c' '' Makefile.linuxx8664icc
    mysed '-fno-f2c -fPIC' '-fPIC' Makefile.linuxx8664icc
    mysed '-fno-second-underscore' '' Makefile.linuxx8664icc
  fi
  if [[ $FC =~ .*gfortran.* ]];
  then
    if [ "$arch" = "linuxx8664gcc" ];
    then
      mysed "OPT   = -O2 -g" "OPT   = ${CXXFLAGS}" Makefile.$arch
      mysed 'LDFLAGS       = $(OPT)' "LDFLAGS       = ${CXXFLAGS_BAK}" Makefile.$arch
      if [ "$compiler" = "Clang" ]; then
        mysed 'CXXOPTS       = $(OPT)' "CXXOPTS       = ${CXXFLAGS_BAK}" Makefile.$arch
        cd $SIMPATH/tools/root
        mypatch ../root_vmc_MakeMacros.diff
      fi
    elif [ "$arch" = "linuxia64gcc" ];
    then
      cp Makefile.linux Makefile.linuxia64gcc
#      mysed "OPT   = -O2" "OPT   =" Makefile.linuxia64gcc
      mysed "-Woverloaded-virtual" "" Makefile.linuxia64gcc
      mysed "-DCERNLIB_LINUX" "-DCERNLIB_LXIA64" Makefile.linuxia64gcc
      mysed "OPT   = -O2" "OPT   =" Makefile.$arch
      mysed "OPT   = -g" "OPT   = ${CXXFLAGS} -fPIC" Makefile.$arch
    fi
  fi

  cd $SIMPATH/tools/root/build_for_fair/
  echo "start install"
  $MAKE_command install

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
