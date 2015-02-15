
	#!/bin/bash
####
# Script to remove all temporary and installed files for the different packages.
# The script also removes all temporary and installed file for dependent packages.
# If you choose to remove e.g. the root package the script will run "make clean"
# in the base directory of root. It will also remove all innstalled files in
# SIMPATH_INSTALL and the calls the function for all packges which depends on
# the root package, e.g. pluto.  
####


main() {

  if [ $# -eq 0 -o $# -gt 2 ];
  then
    print_help
    exit 1
  fi

  package=$1

  if [ $# -eq 2 ];
  then
    rm_installed_files=true
  else  
    rm_installed_files=false
  fi  

  # Extract the directory where the script is loacted 
  SIMPATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
    
  if [ -e $SIMPATH/config.cache ]; then
     source $SIMPATH/config.cache
  else
    echo "Could not find the config.cache file."
    exit 1
  fi

  source $SIMPATH/scripts/package_versions.sh
  source $SIMPATH/scripts/functions.sh
  echo "Check if all variables are properly defined in config.cache."
  check_variables 
  echo "All variables are properly defined in config.cache."

  check_package_exist $package

  clean_$package
  
  cd $SIMPATH_INSTALL

  if [ -e bin/fairsoft-config ]; then
    rm bin/fairsoft-config
    rm include/FairSoftVersion.h
  fi

  find $SIMPATH_INSTALL -type d -empty -delete
  
  # Remove symbolic link if libdir doesn't exist any longer
  if [ ! -e lib -a -L lib64 ]; then
    rm -f lib64
  fi

  exit 0

}

print_help() {
  echo ""
  echo ""
  echo "This shell script will remove temporary files for the package"
  echo "specified by the first parameter. If the second parameter is"
  echo "present the script will also remove the installed files."
  echo "To remove the temporary files of all packages the command is"
  echo "  ./make_clean_install.sh all"
  echo "If the installed and temporary files of all packages should"
  echo "be rmoved the command is"
  echo "  ./make_clean_install.sh all true" 
  echo ""
  echo ""
}

clean_cmake() {
  echo "Remove temporary files from package CMake" 
  if [ -e $SIMPATH/basics/cmake ]; then
    cd $SIMPATH/basics/cmake
    make clean
  fi
  
  if [ "$rm_installed_files" = "true" ]; then
    echo "Remove installed files from package CMake" 
    if [ -e $SIMPATH_INSTALL/bin/cmake ]; then
      cd $SIMPATH/basics/cmake
      make uninstall
      cd $SIMPATH_INSTALL
      rm -rf share/cmake-2.8 share/doc/CMake
    fi
  fi
}

clean_gtest() {
  echo "Remove temporary files from package gtest" 
  if [ -e $SIMPATH/basics/gtest/build ]; then
    rm -rf $SIMPATH/basics/gtest/build
  fi

  if [ "$rm_installed_files" = "true" ]; then
    echo "Remove installed files from package gtest" 
    cd $SIMPATH_INSTALL
    rm -rf include/gtest 
    rm -f lib/libgtest*.a
  fi
}


clean_gsl() {
  echo "Remove temporary files from package gsl" 
  if [ -e $SIMPATH/basics/gsl ]; then
   cd $SIMPATH/basics/gsl
    make clean
  fi

  if [ "$rm_installed_files" = "true" ]; then
    echo "Remove installed files from package gsl" 
    if [ -e $SIMPATH_INSTALL/bin/gsl-config ]; then
      cd $SIMPATH/basics/gsl
      make uninstall
      cd $SIMPATH_INSTALL/lib
      rm -f libgsl*.so
    fi  
  fi

  clean_root
}

clean_icu() {
  if [ "$compiler" = "Clang" -a "$platform" = "linux" ]; then
    echo "Remove temporary files from package icu" 
    echo "Remove installed files from package icu" 
    echo "Not implemented yet"
    # Boost depends on some systems on icu
    # Needed only for linux + clang
    clean_boost
  else
    echo "ICU was not build for this compiler and platform"
  fi
}

clean_boost() {
  echo "Remove temporary files from package boost" 
  if [ -e $SIMPATH/basics/boost ]; then  
    cd $SIMPATH/basics
    #./b2 --clean install
    rm -rf boost $BOOSTVERSION
  fi
    
  if [ "$rm_installed_files" = "true" ]; then
    echo "Remove installed files from package boost" 
    if [ -e $SIMPATH_INSTALL/include/boost ]; then
      cd $SIMPATH_INSTALL
      rm -rf include/boost
      rm -f lib/libboost*
    fi
  fi    
}

clean_pythia6() {
  echo "Remove temporary files from package pythia6" 
  if [ -e $SIMPATH/generators/pythia6/build ]; then  
    rm -rf $SIMPATH/generators/pythia6/build
  fi

  if [ "$rm_installed_files" = "true" ]; then
    echo "Remove installed files from package pythia6" 
    if [ -e $SIMPATH_INSTALL/lib/libPythia6.so ]; then  
      rm -f $SIMPATH_INSTALL/lib/libPythia6*
    fi
  fi    
  clean_root
}

clean_hepmc() {
  echo "Remove temporary files from package hepmc" 
  if [ -e $SIMPATH/generators/build_HepMC ]; then  
    rm -rf $SIMPATH/generators/build_HepMC
  fi

  if [ "$rm_installed_files" = "true" ]; then
    echo "Remove installed files from package hepmc" 
    if [ -e $SIMPATH_INSTALL/lib/libHepMC.a ]; then  
      rm -rf $SIMPATH_INSTALL/include/HepMC
      rm -rf $SIMPATH_INSTALL/share/HepMC
      rm -f $SIMPATH_INSTALL/lib/libHepMC*
    fi
  fi    

  clean_pythia8
}

clean_pythia8() {
  if [ ! $pythia8_cleaned ]; then
    echo "Remove temporary files from package pythia8" 
    if [ -e $SIMPATH/generators/pythia8/lib ]; then  
      cd $SIMPATH/generators/pythia8
      make distclean
    fi

    if [ "$rm_installed_files" = "true" ]; then
      echo "Remove installed files from package pythia8" 
      if [ -e $SIMPATH_INSTALL/lib/libpythia8.so ]; then  
        rm -rf $SIMPATH_INSTALL/include/Pythia8
        rm -rf $SIMPATH_INSTALL/share/pythia8
        rm -f $SIMPATH_INSTALL/lib/libpythia8*
        rm -f $SIMPATH_INSTALL/lib/liblhapdfdummy*
      fi
    fi    
    clean_root
    pythia8_cleaned=true
  fi
}

clean_xercesc() {

  if [ "$build_python" = "yes" ]; then
    if [ "$rm_installed_files" = "true" ]; then
      echo "Remove installed files from package xercesc" 
      cd $SIMPATH/basics/xercesc
      make uninstall
      cd $SIMPATH_INSTALL/lib
      rm -f libxerces*
    fi

    echo "Remove temporary files from package xercesc" 
    if [ -e $SIMPATH/basics/xercesc ]; then  
      cd $SIMPATH/basics/xercesc
      make clean
    fi
    clean_geant4
  else
    echo "XercesC was not build for the current settings"
  fi
}

clean_mesa() {
  if [ "$compiler" = "Clang" -a "$platform" = "linux" ]; then
    echo "Remove temporary files from package mesa" 
    echo "Remove installed files from package mesa" 
    echo "Not implemented yet"
    # Geant4 and Root depend on Mesa/OpenGl
    # needed only for linux + clang
    clean_geant4
    clean_root
  else
    echo "Mesa was not build for this compiler and platform"
  fi
}

clean_geant4() {

  if [ ! $geant4_cleaned ]; then
    echo "Remove temporary files from package geant4" 
    if [ -e $SIMPATH/transport/geant4/build ]; then  
      rm -rf $SIMPATH/transport/geant4/build
    fi

    if [ "$rm_installed_files" = "true" ]; then
      echo "Remove installed files from package geant4" 
      if [ -e $SIMPATH_INSTALL/lib/libG3toG4.so ]; then  
        rm -rf $SIMPATH_INSTALL/include/Geant4
        rm -r $SIMPATH_INSTALL/share/Geant4
        rm -rf $SIMPATH_INSTALL/share/$GEANT4VERSIONp
        rm -f $SIMPATH_INSTALL/bin/geant4*
        rm -f $SIMPATH_INSTALL/lib/libG4*
        rm -f $SIMPATH_INSTALL/lib/libG3toG4*
        rm -rf $SIMPATH_INSTALL/lib/$GEANT4VERSIONp
      fi
    fi    

    # Root, vgm  and geant4_vmc depend on geant4
    clean_root
    clean_g4py
    clean_geant4_vmc
    clean_vgm
    geant4_cleaned=true
  fi
}

clean_xrootd() {

  if [ "$rm_installed_files" = "true" ]; then
    echo "Remove installed files from package xrootd" 
    cd $SIMPATH_INSTALL/bin
    rm -f cconfig cmsd cns_ssi frm_admin frm_purged frm_xfragent frm_xfrd mpxstats wait41 xprep xrd xrdadler32 XrdCnsd xrdcopy xrdcp xrdcp-old xrdfs xrdgsiproxy xrdmapc xrdpwdadmin xrdsssadmin xrdstagetool xrootd xrootd-config
    cd $SIMPATH_INSTALL/include
    rm -rf xrootd
    cd $SIMPATH_INSTALL/lib
    rm -f libXrd*
    cd $SIMPATH_INSTALL/share/man/man1
    rm -f xrd*
    rm -f xprep*
    cd $SIMPATH_INSTALL/share/man/man8
    rm -f cmsd* cns* frm* mpx* Xrd* xr*
    cd $SIMPATH_INSTALL/share
    rm -rf xrootd
  fi
  clean_root
}


clean_root() {

  if [ ! $root_cleaned ]; then
    if [ "$rm_installed_files" = "true" ]; then
      echo "Remove installed files from package root" 
      cd $SIMPATH/tools/root
      make uninstall
      cd $SIMPATH_INSTALL
      rm -rf lib/root
      rm -rf include/root
    fi

    echo "Remove temporary files from package root" 
    if [ -e $SIMPATH/tools/root ]; then  
      cd $SIMPATH/tools/root
      make clean
    fi

    clean_pluto
    clean_vgm
    clean_geant4_vmc
    clean_geant3  
    root_cleaned=true
  fi
}

clean_g4py() {
  if [ ! $g4py_cleaned ]; then
    if [ "$build_python" = "yes" ]; then

      echo "Remove temporary files from package g4py" 
      if [ -e $SIMPATH/transport/geant4/build_g4py ]; then  
        rm -rf $SIMPATH/transport/geant4/build_g4py
      fi
      if [ "$rm_installed_files" = "true" ]; then
        echo "Remove installed files from package g4py" 
        if [ -e $SIMPATH_INSTALL/lib/g4py ]; then  
          rm -rf $SIMPATH_INSTALL/lib/g4py
          rm -rf $SIMPATH_INSTALL/lib/Geant4
        fi
      fi
    else
      echo "g4py was not build for the current settings"
    fi
    g4py_cleaned=true
  fi
}

clean_pluto() {
  if [ ! $pluto_cleaned ]; then
    echo "Remove temporary files from package pluto" 
    if [ -e $SIMPATH/generators/pluto/Makefile ]; then
      cd $SIMPATH/generators/pluto
      make clean
      make pluginclean
    fi

    if [ "$rm_installed_files" = "true" ]; then
      echo "Remove installed files from package pluto" 
      if [ -e $SIMPATH_INSTALL/lib/libPluto.a ]; then  
        rm -f $SIMPATH_INSTALL/lib/libPluto*
        rm -rf $SIMPATH_INSTALL/include/pluto
      fi
    fi
    pluto_cleaned=true
  fi
}


clean_geant3() {

  if [ ! $geant3_cleaned ]; then
    echo "Remove temporary files from package geant3" 
    if [ -e $SIMPATH/transport/geant3/lib ]; then
      rm -rf $SIMPATH/transport/geant3/lib
      rm -rf $SIMPATH/transport/geant3/tgt_*
    fi
    if [ "$rm_installed_files" = "true" ]; then
      echo "Remove installed files from package geant3" 
      if [ -e $SIMPATH_INSTALL/lib/libgeant321.so ]; then  
        rm -f $SIMPATH_INSTALL/lib/libgeant321.so
        rm -rf $SIMPATH_INSTALL/include/TGeant3
        rm -rf $SIMPATH_INSTALL/share/geant3
      fi
    fi
    geant3_cleaned=true
  fi
}

clean_vgm() {
  if [ ! $vgm_cleaned ]; then
    echo "Remove temporary files from package vgm" 
    if [ -e $SIMPATH/transport/vgm/build_cmake ]; then
      rm -rf $SIMPATH/transport/vgm/build_cmake
    fi
    if [ "$rm_installed_files" = "true" ]; then
      echo "Remove installed files from package vgm" 
      if [ -e $SIMPATH_INSTALL/lib/libBaseVGM.so ]; then  
        rm -f $SIMPATH_INSTALL/lib/lib*GM.*
        rm -rf $SIMPATH_INSTALL/include/*GM
      fi
    fi
    clean_geant4_vmc
    vgm_cleaned=true
  fi
}

clean_geant4_vmc() {

  if [ ! $geant4_vmc_cleaned ]; then
    echo "Remove temporary files from package geant4_vmc" 
    if [ -e $SIMPATH/transport/geant4_vmc/tmp ]; then
      rm -rf $SIMPATH/transport/geant4_vmc/tmp
      rm -rf $SIMPATH/transport/geant4_vmc/lib
      rm -rf $SIMPATH/transport/geant4_vmc/include
    fi

    if [ "$rm_installed_files" = "true" ]; then
      echo "Remove installed files from package geant4_vmc" 
      if [ -e $SIMPATH_INSTALL/lib/libg4root.so ]; then  
        rm -f $SIMPATH_INSTALL/lib/libg4root.*
        rm -f $SIMPATH_INSTALL/lib/libgeant4vmc.*
        rm -rf $SIMPATH_INSTALL/include/geant4vmc
        rm -rf $SIMPATH_INSTALL/share/geant4_vmc
      fi
    fi
    geant4_vmc_cleaned=true
  fi
}

clean_millipede() {
  echo "Remove temporary files from package millipede" 
  if [ -e $SIMPATH/basics/MillepedeII/build ]; then
    rm -rf $SIMPATH/basics/MillepedeII/build
    cd $SIMPATH/basics/MillepedeII
    make clean
    rm -f $SIMPATH/basics/MillepedeII/pede
  fi

  if [ "$rm_installed_files" = "true" ]; then
    echo "Remove installed files from package millipede" 
    if [ -e $SIMPATH_INSTALL/lib/libMille.so ]; then  
      rm -f $SIMPATH_INSTALL/lib/libMille.*
      rm -f $SIMPATH_INSTALL/include/Mille.h
      rm -f $SIMPATH_INSTALL/bin/pede
    fi
  fi
}

clean_zeromq() {
  echo "Remove temporary files from package zeromq" 
  if [ -e $SIMPATH/basics/zeromq ]; then
    cd $SIMPATH/basics/zeromq
    make clean
  fi

  if [ "$rm_installed_files" = "true" ]; then
    echo "Remove installed files from package zeromq" 
    if [ -e $SIMPATH_INSTALL/lib/libzmq.a ]; then  
      cd $SIMPATH/basics/zeromq
      make uninstall
      cd $SIMPATH_INSTALL
      rm -f lib/libzmq.*
      rm -f include/zmq.hpp
    fi
  fi
}

clean_protobuf() {
  echo "Remove temporary files from package protobuf" 
  if [ -e $SIMPATH/basics/protobuf ]; then
    cd $SIMPATH/basics/protobuf
    make clean
  fi
  if [ "$rm_installed_files" = "true" ]; then
    echo "Remove installed files from package protobuf" 
    if [ -e $SIMPATH_INSTALL/bin/protoc ]; then  
      cd $SIMPATH/basics/protobuf
      make uninstall
    fi
  fi
}


clean_nanomsg() {
  echo "Remove temporary files from package nanomsg" 
  if [ -e $SIMPATH/basics/nanomsg ]; then
    cd $SIMPATH/basics/nanomsg
    make clean
  fi

  if [ "$rm_installed_files" = "true" ]; then
    echo "Remove installed files from package nanomsg" 
    if [ -e $SIMPATH_INSTALL/bin/nanocat ]; then  
      cd $SIMPATH/basics/nanomsg
      make uninstall
      rm -f $SIMPATH_INSTALL/bin/nn_*
    fi
  fi
}

clean_all() {
  valid_packages="cmake gtest gsl icu boost pythia6 hepmc pythia8 xercesc mesa geant4 xrootd root g4py pluto geant3 vgm geant4_vmc millipede zeromq protobuf nanomsg"

  for pack in $valid_packages
  do
    clean_$pack
  done
}

check_package_exist() {
  valid_packages="cmake gtest gsl icu boost pythia6 hepmc pythia8 xercesc mesa geant4 xrootd root g4py pluto geant3 vgm geant4_vmc millipede zeromq protobuf nanomsg"

  if [ "$1" = "all" ]; then
    return
  fi

  for pack in $valid_packages
  do
    if [ "$1" = "$pack" ]; then
      return 
    fi
  done
 
  echo "The package \"$1\" is not a valid package name."
  echo "Valid package names are: "
  for pack in $valid_packages
  do
    echo "  $pack"
  done
  exit 1
}

# call the main function after all other functions are already defined
main "$@"

exit
