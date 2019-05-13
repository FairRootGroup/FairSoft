################################################################################
#    Copyright (C) 2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH    #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################
if(CMAKE_BINARY_DIR STREQUAL CMAKE_SOURCE_DIR)
  message(FATAL_ERROR "In-source builds are not supported.")
endif()

cmake_minimum_required(VERSION 3.11 FATAL_ERROR)
cmake_policy(VERSION 3.11...3.15)

project(FairSoft LANGUAGES C CXX Fortran)
set(FairSoft_VERSION jun19p1)

find_package(Git)
if(GIT_FOUND)

endif()

# Options ######################################################################
if(NOT DEFINED BUILD_METHOD)
  set(BUILD_METHOD spack)
endif()
set(BUILD_METHOD ${BUILD_METHOD} CACHE STRING
  "Whether to build via legacy shell scripts or to invoke new spack-based build - choices: spack, legacy")

include(cmake/legacy_options.cmake)
include(cmake/spack_options.cmake)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "$ENV{HOME}/fairsoft/${FairSoft_VERSION}" CACHE PATH
    "FairSoft installation prefix" FORCE)
endif()

message(STATUS "FairSoft version: ${FairSoft_VERSION}")
message(STATUS "Install prefix: ${CMAKE_INSTALL_PREFIX}")

if(BUILD_METHOD STREQUAL spack)
  # SPACK MODE #################################################################

  # Configure ##################################################################
  # TODO git submodule update --init
  # TODO setup environment, maybe generate module file?
  # TODO generate spack configuration

  # Build ######################################################################
  # TODO add_custom_target(SpackBuild ALL spack install)

  # Install ####################################################################
  # TODO spack commands to create spack env via install(SCRIPT ...)

  # Test #######################################################################
  # TODO add_test(...) specific to spack build
elseif(BUILD_METHOD STREQUAL legacy)
  # LEGACY MODE ################################################################

  # Configure ##################################################################
  file(COPY legacy DESTINATION ${CMAKE_BINARY_DIR})
  configure_file(cmake/legacy.conf.in legacy/generated.conf @ONLY)

  # Build ######################################################################
  add_custom_target(LegacyBuild ALL
    ./configure.sh generated.conf
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/legacy
    COMMENT "Building and installing FairSoft via legacy shell scripts to ${CMAKE_INSTALL_PREFIX}"
    VERBATIM)

  # NO Install #################################################################

  # Test #######################################################################
  # TODO add_test(...) specific to legacy build
else()
  message(FATAL_ERROR "Unknown BUILD_METHOD=${BUILD_METHOD}. Must be either spack or legacy.")
endif()

# Test #######################################################################
# TODO add_test(...) common to both builds