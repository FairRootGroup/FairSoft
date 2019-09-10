################################################################################
#    Copyright (C) 2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH    #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################

if(NOT DEFINED LEGACY_COMPILER)
  if(APPLE)
    set(LEGACY_COMPILER Clang)
  else()
    set(LEGACY_COMPILER gcc)
  endif()
endif()
set(LEGACY_COMPILER ${LEGACY_COMPILER} CACHE STRING
  "Legacy build option to choose compiler - choices: gcc, intel, CC, PGI, Clang")

if(NOT DEFINED LEGACY_DEBUG)
  set(LEGACY_DEBUG no)
endif()
set(LEGACY_DEBUG ${LEGACY_DEBUG} CACHE STRING
  "Legacy build option to enable debug info - choices: yes, no")

if(NOT DEFINED LEGACY_OPTIMIZE)
  set(LEGACY_OPTIMIZE yes)
endif()
set(LEGACY_OPTIMIZE ${LEGACY_OPTIMIZE} CACHE STRING
  "Legacy build option to enable the optimizer - choices: yes, no")

if(NOT DEFINED LEGACY_PACKAGES)
  set(LEGACY_PACKAGES All)
endif()
set(LEGACY_PACKAGES ${LEGACY_PACKAGES} CACHE STRING
  "Legacy build option to choose which FairSoft tree to install - choices: All")

if(NOT DEFINED LEGACY_GEANT4_DATA)
  set(LEGACY_GEANT4_DATA download)
endif()
set(LEGACY_GEANT4_DATA ${LEGACY_GEANT4_DATA} CACHE STRING
  "Legacy build option to choose whether and how to install Geant4 data files - choices: no, download, directory")

if(LEGACY_GEANT4_DATA STREQUAL no)
  set(LEGACY_GEANT4_DATA_DOWNLOAD no)
  set(LEGACY_GEANT4_DATA_FROM_DIR no)
elseif(LEGACY_GEANT4_DATA STREQUAL download)
  set(LEGACY_GEANT4_DATA_DOWNLOAD yes)
  set(LEGACY_GEANT4_DATA_FROM_DIR no)
elseif(LEGACY_GEANT4_DATA STREQUAL directory)
  set(LEGACY_GEANT4_DATA_DOWNLOAD no)
  set(LEGACY_GEANT4_DATA_FROM_DIR yes)
endif()

if(NOT DEFINED LEGACY_GEANT4_MT)
  set(LEGACY_GEANT4_MT no)
endif()
set(LEGACY_GEANT4_MT ${LEGACY_GEANT4_MT} CACHE STRING
  "Legacy build option to enable Geant4 multithreaded build - choices: yes, no")

if(NOT DEFINED LEGACY_SIM)
  set(LEGACY_SIM yes)
endif()
set(LEGACY_SIM ${LEGACY_SIM} CACHE STRING
  "Legacy build option to enable simulation engines and event generators - choices: yes, no")

if(NOT DEFINED LEGACY_PYTHON)
  set(LEGACY_PYTHON yes)
endif()
set(LEGACY_PYTHON ${LEGACY_PYTHON} CACHE STRING
  "Legacy build option to enable building of ROOT's python features - choices: yes, no")

if(NOT DEFINED LEGACY_FAIRMQ_ONLY)
  set(LEGACY_FAIRMQ_ONLY no)
endif()
set(LEGACY_FAIRMQ_ONLY ${LEGACY_FAIRMQ_ONLY} CACHE STRING
  "Legacy build option to select only FairMQ related packages - choices: yes, no, depsonly")
