#!/bin/bash
#
# CBM package compilation script
# m.al-turany@gsi.de, June 2006
# protopop@jlab.org, June 2006
# update of the script
# include debug version and
# intel compiler switches
# f.uhlig@gsi.de, July 2007

# debug options on :set -xv
# debug options off:set +xv
#
set +xv

# unset ROOTSYS. If it is set this can make problems when compiling Geant3
unset ROOTSYS

#Clean the enviroment
unset ROOTBUILD
unset THREAD
unset ZLIB
unset LZMA
unset OPENGL
unset MYSQL
unset ORACLE
unset PGSQL
unset SQLITE
unset QTDIR
unset SAPDB
unset RFIO
unset CASTOR
unset GFAL
unset GSL
unset HDFS
unset PYTHIA6
unset PYTHIA8
unset FFTW3
unset CFITSIO
unset GVIZ
unset PYTHONDIR
unset DCACHE
unset CHIRP
unset DNSSD
unset AVAHI
unset ALIEN
unset ASIMAGE
unset LDAP
unset GLOBUS_LOCATION
unset GLITE
unset MEMSTAT
unset MONALISA
unset SRP
unset SSL
unset AFS
unset ROOFIT
unset MINUIT2
unset TABLE
unset XMLDIR
unset ROOTDICTTYPE
unset PLATFORM

export SIMPATH=$PWD

# Set the cache file name
cache_file="config.cache"

# define the logfile
datum=$(date +%d%m%y_%H%M%S)
logfile=$PWD/Install_$datum.log
logfile_lib=$PWD/libraries_$datum.log
echo "The build process for the external packages for the FairRoot Project was started at" $datum | tee -a $logfile

source scripts/functions.sh

# check if there was a parameter given to the script.
# if yes then use some standard parameters and don't
# show the menus. Else get some input interactively.
if [ $# == "0" ];
then
  source scripts/menu.sh
elif [ $# == "1" ];
then
  # test if the file exist and if all needed varaibles are defined in the script
  if [ -e $1 ]; then
    source $1
    check_variables
  else
    echo "The file passed as parameter does not exist."
    exit 1
  fi
else
  echo "Call the script either with no parameter, then your are guided through the installation procedure,"
  echo "or with one parameter which defines an input file with the needed parameters."
  exit 1
fi
if [ "$build_MQOnly" = "yes" ]
then
    mqonly=1
    mqdepsonly=0
elif [ "$build_MQOnly" = "depsonly" ]
then
    mqonly=1
    mqdepsonly=1
else
    mqonly=0
    mqdepsonly=0
fi

if [ "$install_sim" = "yes" ]
then
   onlyreco=0
   export Fortran_Needed=TRUE
elif [ "$install_sim" = "no" ]
then
   onlyreco=1
   export Fortran_Needed=FALSE
fi
if [ "$build_MQOnly" = "no" ]
then
     if [ "$build_root6" = "yes" ]
     then
       export Root_Version=6
     elif [ "$build_root6" = "no" ]
     then
       export Root_Version=5
     fi
 elif [ "$build_MQOnly" = "yes" ];
 then
    export Root_Version=0
fi

if [ "$installation_type" = "grid" ];
then
  export BUILD_BATCH=TRUE
else
  export BUILD_BATCH=FALSE
fi

if [ "$build_python" = "yes" ];
then
  export BUILD_PYTHON=TRUE
else
  export BUILD_PYTHON=FALSE
fi

export SIMPATH_INSTALL

# check the architecture automatically
# set the compiler options according to architecture, compiler
# debug and optimization options
source scripts/check_system.sh

# generate the config.cache file
generate_config_cache

echo "The following parameters are set." | tee -a $logfile
echo "System              : " $system | tee -a $logfile
echo "C++ compiler        : " $CXX | tee -a $logfile
echo "C compiler          : " $CC | tee -a $logfile
echo "Fortran compiler    : " $FC | tee -a $logfile
echo "CXXFLAGS            : " $CXXFLAGS | tee -a $logfile
echo "CFLAGS              : " $CFLAGS | tee -a $logfile
echo "FFLAGS              : " $FFLAGS | tee -a $logfile
echo "CMAKE BUILD TYPE    : " $BUILD_TYPE | tee -a $logfile
echo "Compiler            : " $compiler | tee -a $logfile
echo "Fortran compiler    : " $FC
echo "Debug               : " $debug | tee -a $logfile
echo "Optimization        : " $optimize | tee -a $logfile
echo "Platform            : " $platform | tee -a $logfile
echo "Architecture        : " $arch | tee -a $logfile
echo "G4System            : " $geant4_system | tee -a $logfile
echo "g4_data_files       : " $geant4_data_files | tee -a $logfile
echo "g4_get_data         : " $geant4_get_data | tee -a $logfile
echo "build G4 with MT    : " $geant4mt | tee -a $logfile
echo "Number of parallel    " | tee -a $logfile
echo "processes for build : " $number_of_processes | tee -a $logfile
echo "Installation Directory: " $SIMPATH_INSTALL | tee -a $logfile

if [ "$onlyreco" = "1" ];
then
  echo "Reco Only Installation  "
fi

check=1

# set the versions of packages to be build
source scripts/package_versions.sh

# Create the installation directory and its substructure
create_installation_directories

# Now start compilations with checks

######################## CMake ################################
# This is only for safety reasons. If we find a machine where
# cmake is not installed, we install cmake and add the path
# to the environment variable PATH

if [ "$check" = "1" ];
then
  source scripts/install_cmake.sh
fi

############ Google Test framework ###############################

if [ "$check" = "1" ];
then
  source scripts/install_gtest.sh
fi

############ GNU scientific library ###############################

if [ "$check" = "1" ];
then
  source scripts/install_gsl.sh
fi

##################### Vc #############################################

if [ "$check" = "1" ];
then
  source scripts/install_vc.sh
fi

############ ICU libraries ###############################

if [ "$check" = "1" -a "$compiler" = "Clang" -a "$platform" = "linux" ];
then
  source scripts/install_icu.sh
fi

############ Boost libraries ###############################

if [ "$check" = "1" ];
then
  source scripts/install_boost.sh
fi

##################### Pythia 6 #############################################

if [ "$check" = "1" -a "$onlyreco" = "0" ];
then
  source scripts/install_pythia6.sh
fi

##################### HepMC ## #############################################

if [ "$check" = "1" -a "$onlyreco" = "0" ];
then
  source scripts/install_hepmc.sh
fi

##################### Pythia 8 #############################################

if [ "$check" = "1" -a "$onlyreco" = "0" ];
then
  source scripts/install_pythia8.sh
fi

##################### XercesC #############################################

if [ "$build_python" = "yes" ];
then
  if [ "$check" = "1" -a "$onlyreco" = "0" ];
  then
    source scripts/install_xercesc.sh
  fi
fi

############ Mesa libraries ###############################

if [ "$check" = "1" -a "$compiler" = "Clang" -a "$platform" = "linux" -a "$mqonly" = "0" ];
then
  source scripts/install_mesa.sh
fi

##################### GEANT 4 #############################################

if [ "$check" = "1" -a "$onlyreco" = "0" ];
then
  source scripts/install_geant4.sh
fi

###################### GEANT 4 Data ########################################

if [ "$check" = "1" -a "$geant4_install_data_from_dir" = "yes" -a "$onlyreco" = "0" ];
then
  source scripts/install_geant4_data.sh
fi

##################### ROOT #############################################

if [ "$check" = "1" -a "$mqonly" = "0" ];
then
  source scripts/install_root6.sh
fi

##################### G4Py #############################################

if [ "$build_python" = "yes" ];
then
  if [ "$check" = "1" -a "$onlyreco" = "0" -a "$mqonly" = "0" ];
  then
    source scripts/install_g4py.sh
  fi
fi

##################### Geant 3 VMC #############################################

if [ "$check" = "1" -a "$onlyreco" = "0" -a "$mqonly" = "0" ];
then
  source scripts/install_geant3.sh
fi

##################### VGM #############################################

if [ "$check" = "1" -a "$onlyreco" = "0" ];
then
    source scripts/install_vgm.sh
fi

##################### Geant 4 VMC #############################################

if [ "$check" = "1" -a "$onlyreco" = "0" ];
then
  source scripts/install_geant4_vmc.sh
fi

##################### Millepede #############################################

if [ "$check" = "1" -a "$onlyreco" = "0" ];
then
  source scripts/install_millepede.sh
fi

##################### LibSodium ##################################################

#if [ "$check" = "1" ];
#then
#  source scripts/install_sodium.sh
#fi

##################### ZeroMQ ##################################################

if [ "$check" = "1" ];
then
  source scripts/install_zeromq.sh
fi

##################### Protocoll Buffers #######################################

if [ "$check" = "1" ];
then
  source scripts/install_protobuf.sh
fi

##################### FlatBuffers ##############################################

if [ "$check" = "1" ];
then
  source scripts/install_flatbuffers.sh
fi

##################### MessagePack ##############################################

if [ "$check" = "1" ];
then
  source scripts/install_msgpack.sh
fi

##################### nanomsg ##################################################

if [ "$check" = "1" ];
then
  source scripts/install_nanomsg.sh
fi

##################### yaml-cpp ##################################################

if [ "$check" = "1" ];
then
  source scripts/install_yamlcpp.sh
fi

##################### DDS ###############################################

if [ "$check" = "1" ];
then
  source scripts/install_DDS.sh
fi

##################### FairLogger ###############################################

if [ "$check" = "1" ];
then
  source scripts/install_fairlogger.sh
fi

##################### OFI ###############################################

#if [ "$check" = "1" -a "$platform" = "linux" ];
#then
#  source scripts/install_ofi.sh
#fi

##################### asiofi ###############################################

#if [ "$check" = "1" -a "$platform" = "linux" ];
#then
#  source scripts/install_asiofi.sh
#fi

##################### FairMQ ###############################################

if [ "$check" = "1" -a "$mqdepsonly" = "0" ];
then
  source scripts/install_fairmq.sh
fi

if [ "$check" = "1" ];
then
    echo "*** End installation of external packages without Errors***"  | tee -a $logfile
    echo ""
    if [ "$install_cmake" = "yes" ]; then
      echo "During the installation a new version of CMake has been installed in $SIMPATH_INSTALL/bin."
      echo "Please add this path to your environment variable PATH to use this new version of CMake."
    fi
    if [ "$install_alfasoft" = "yes" ];
    then
      echo "----------------- End of FairSoft installation ---------------"
    else
      exit 0
    fi
else
    echo "*** End installation of external packages with Errors***"  | tee -a $logfile
    exit 42
fi
