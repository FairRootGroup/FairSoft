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
enable_testing()

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

  Include(cmake/SetFairSoftFlags.cmake)
  SetFairSoftFlags()

  # Configure ##################################################################
  # TODO git submodule update --init
  # TODO setup environment, maybe generate module file?
  # TODO generate spack configuration

  # Update spack submodule
  execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

  # Change default location for packages and module files
  if(NOT EXISTS ${CMAKE_BINARY_DIR}/.spack)
    execute_process(COMMAND "mkdir ${CMAKE_BINARY_DIR}/.spack")
  endif()

  file(WRITE ${CMAKE_BINARY_DIR}/.spack/config.yaml "config:\n\
  install_tree: ${CMAKE_INSTALL_PREFIX}/opt/spack\n\
  module_roots:\n\
    tcl: ${CMAKE_INSTALL_PREFIX}/share/spack/modules\n\
    lmod: ${CMAKE_INSTALL_PREFIX}/share/spack/lmod\n\
    dotkit: ${CMAKE_INSTALL_PREFIX}/share/spack/dotkit")

  # If on macOS - take libiconv from system
  if(CMAKE_SYSTEM_NAME MATCHES "Darwin")
    execute_process(COMMAND ./spack/bin/spack compiler info clang WORKING_DIRECTORY
        ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE SPACK_CLANG_INFO_STRING
        ERROR_VARIABLE SPACK_CLANG_INFO_ERROR)
    if("${SPACK_CLANG_INFO_STRING}" STREQUAL "")
      Message(FATAL_ERROR "spack could not find clang compiler. ${SPACK_CLANG_INFO_ERROR}")
    endif()
    string(REPLACE "\n" ";" SPACK_CLANG_INFO_LIST ${SPACK_CLANG_INFO_STRING})
    list(GET SPACK_CLANG_INFO_LIST 0 SPACK_CLANG_INFO_T)
    string(REPLACE ":" "" SPACK_CLANG_INFO ${SPACK_CLANG_INFO_T})

    if(NOT EXISTS ${CMAKE_BINARY_DIR}/.spack/darwin)
      execute_process(COMMAND "mkdir ${CMAKE_BINARY_DIR}/.spack/darwin")
    endif()

    file(WRITE ${CMAKE_BINARY_DIR}/.spack/darwin/packages.yaml "packages:\n\
  libiconv:\n\
    paths:\n\
      libiconv@1.16%${SPACK_CLANG_INFO} arch=darwin-macos-x86_64: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr")
  endif()

  # If not yet done - add fairsoft repo to spack
  execute_process(COMMAND ./spack/bin/spack repo list WORKING_DIRECTORY
      ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE SPACK_REPOS)
  string(FIND ${SPACK_REPOS} "${CMAKE_SOURCE_DIR}\n" POS_FOUND)
  if(${POS_FOUND} EQUAL -1)
    execute_process(COMMAND ./spack/bin/spack repo add ${CMAKE_SOURCE_DIR}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
  endif()

  # Build ######################################################################
  # TODO add_custom_target(SpackBuild ALL spack install)

  # Install fairroot and dependencies
  add_custom_target(SpackBuild ALL ${CMAKE_SOURCE_DIR}/spack/bin/spack -C
      ${CMAKE_BINARY_DIR}/.spack install
      fairroot@18.2.1)

  # Generate fairsoft-config script
  Configure_File(${CMAKE_SOURCE_DIR}/cmake/fairsoft-config.in
      ${CMAKE_INSTALL_PREFIX}/fairsoft/bin/fairsoft-config @ONLY)

  # Install ####################################################################
  # TODO spack commands to create spack env via install(SCRIPT ...)

  # Put links to all packages into one installation folder
  install(CODE "execute_process(COMMAND ./spack/bin/spack -C \
${CMAKE_BINARY_DIR}/.spack view --verbose \
symlink -i ${CMAKE_INSTALL_PREFIX}/fairsoft fairroot WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})")

  # Test #######################################################################
  # TODO add_test(...) specific to spack build
# set(SPACK_DIR $ENV{SPACK_DIR})
# set(FAIRROOT_VERSION $ENV{FAIRROOT_VERSION})
# set(SPACK_EXTRA_FLAGS $ENV{SPACK_EXTRA_FLAGS})
#
# configure_file(${CMAKE_SOURCE_DIR}/test/cmaketest.sh.in ${CMAKE_BINARY_DIR}/test/cmaketest.sh)
# add_test(NAME build_fairroot_spack COMMAND ${CMAKE_BINARY_DIR}/test/cmaketest.sh)
# set_tests_properties(build_fairroot_spack PROPERTIES TIMEOUT 14400)
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
