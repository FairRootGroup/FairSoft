################################################################################
#    Copyright (C) 2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH    #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################

if(NOT DEFINED BUILD_METHOD)
  set(BUILD_METHOD spack)
endif()
set(BUILD_METHOD ${BUILD_METHOD} CACHE STRING
  "Whether to build via legacy shell scripts or to invoke new spack-based build - choices: spack, legacy")

if(NOT DEFINED FAIRSOFT_COMPILER)
  if(APPLE)
    set(FAIRSOFT_COMPILER Clang)
  else()
    set(FAIRSOFT_COMPILER gcc)
  endif()
endif()
set(FAIRSOFT_COMPILER ${FAIRSOFT_COMPILER} CACHE STRING
  "Legacy build option to choose compiler - choices: gcc, intel, CC, PGI, Clang")

if(NOT DEFINED FAIRSOFT_DEBUG)
  set(FAIRSOFT_DEBUG no)
endif()
set(FAIRSOFT_DEBUG ${FAIRSOFT_DEBUG} CACHE STRING
  "Legacy build option to enable debug info - choices: yes, no")

if(NOT DEFINED FAIRSOFT_OPTIMIZE)
  set(FAIRSOFT_OPTIMIZE yes)
endif()
set(FAIRSOFT_OPTIMIZE ${FAIRSOFT_OPTIMIZE} CACHE STRING
  "Legacy build option to enable the optimizer - choices: yes, no")

if(NOT DEFINED _FAIRSOFT_SIM)
  set(_FAIRSOFT_SIM yes)
endif()
if(NOT DEFINED _FAIRSOFT_FAIRMQ_ONLY)
  set(_FAIRSOFT_FAIRMQ_ONLY no)
endif()

if(NOT DEFINED FAIRSOFT_PACKAGES)
  set(FAIRSOFT_PACKAGES full)
endif()
set(FAIRSOFT_PACKAGES ${FAIRSOFT_PACKAGES} CACHE STRING
  "Build option to choose which FairSoft tree to install")
if(FAIRSOFT_PACKAGES STREQUAL full)
  set(_FAIRSOFT_SIM yes)
  set(_FAIRSOFT_FAIRMQ_ONLY no)
elseif(FAIRSOFT_PACKAGES STREQUAL light)
  set(_FAIRSOFT_SIM no)
  set(_FAIRSOFT_FAIRMQ_ONLY no)
elseif(FAIRSOFT_PACKAGES STREQUAL fairmq)
  set(_FAIRSOFT_SIM no)
  set(_FAIRSOFT_FAIRMQ_ONLY yes)
elseif(FAIRSOFT_PACKAGES STREQUAL fairmqdeps)
  set(_FAIRSOFT_SIM no)
  set(_FAIRSOFT_FAIRMQ_ONLY depsonly)
endif()

if(NOT DEFINED FAIRSOFT_GEANT4_DATA)
  set(FAIRSOFT_GEANT4_DATA download)
endif()
set(FAIRSOFT_GEANT4_DATA ${FAIRSOFT_GEANT4_DATA} CACHE STRING
  "Build option to choose whether and how to install Geant4 data files - choices: no, download, directory")

if(FAIRSOFT_GEANT4_DATA STREQUAL no)
  set(FAIRSOFT_GEANT4_DATA_DOWNLOAD no)
  set(FAIRSOFT_GEANT4_DATA_FROM_DIR no)
elseif(FAIRSOFT_GEANT4_DATA STREQUAL download)
  set(FAIRSOFT_GEANT4_DATA_DOWNLOAD yes)
  set(FAIRSOFT_GEANT4_DATA_FROM_DIR no)
elseif(FAIRSOFT_GEANT4_DATA STREQUAL directory)
  set(FAIRSOFT_GEANT4_DATA_DOWNLOAD no)
  set(FAIRSOFT_GEANT4_DATA_FROM_DIR yes)
endif()

if(NOT DEFINED FAIRSOFT_GEANT4_MT)
  set(FAIRSOFT_GEANT4_MT no)
endif()
set(FAIRSOFT_GEANT4_MT ${FAIRSOFT_GEANT4_MT} CACHE STRING
  "Build option to enable Geant4 multithreaded build - choices: yes, no")

if(NOT DEFINED FAIRSOFT_PYTHON)
  set(FAIRSOFT_PYTHON yes)
endif()
set(FAIRSOFT_PYTHON ${FAIRSOFT_PYTHON} CACHE STRING
  "Build option to enable building of ROOT's python features - choices: yes, no")

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "$ENV{HOME}/fairsoft/${FairSoft_VERSION}" CACHE PATH
    "FairSoft installation prefix" FORCE)
endif()
