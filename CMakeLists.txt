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

cmake_minimum_required(VERSION 3.0 FATAL_ERROR)
cmake_policy(VERSION 3.0...3.15)

project(FairSoft LANGUAGES C CXX Fortran)
set(FairSoft_VERSION jun19p1)

find_package(Git)

include(CTest)

# Options ######################################################################
include(cmake/options.cmake)

message(STATUS "FairSoft version: ${FairSoft_VERSION}")
message(STATUS "Install prefix: ${CMAKE_INSTALL_PREFIX}")

if(BUILD_METHOD STREQUAL spack)
  # SPACK MODE #################################################################

  Include(cmake/SetFairSoftFlags.cmake)
  SetFairSoftFlags()

  # Configure ##################################################################

  # Update spack submodule
  if(GIT_FOUND)
    execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
  endif()

  # Change default location for packages and module files
  if(NOT EXISTS ${CMAKE_BINARY_DIR}/.spack)
    execute_process(COMMAND "mkdir ${CMAKE_BINARY_DIR}/.spack")
  endif()

  execute_process(COMMAND ./spack/bin/spack compilers WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

  file(WRITE ${CMAKE_BINARY_DIR}/.spack/config.yaml "config:\n\
  install_tree: ${CMAKE_INSTALL_PREFIX}/opt/spack\n\
  module_roots:\n\
    tcl: ${CMAKE_INSTALL_PREFIX}/share/spack/modules\n\
    lmod: ${CMAKE_INSTALL_PREFIX}/share/spack/lmod\n\
    dotkit: ${CMAKE_INSTALL_PREFIX}/share/spack/dotkit\n\
  source_cache: ${CMAKE_BINARY_DIR}/var/spack/cache\n\
  build_stage:\n\
    - ${CMAKE_BINARY_DIR}/var/spack/stage")

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

    execute_process(COMMAND sw_vers OUTPUT_VARIABLE MACOS_VERSION)
    string(REPLACE "\n" ";" MACOS_VERSION ${MACOS_VERSION})
    list(GET MACOS_VERSION 1 MACOS_VERSION)
    string(REGEX MATCH "[0-9][0-9].[0-9][0-9]+" MACOS_VERSION ${MACOS_VERSION})
    Message(STATUS "macOS version ${MACOS_VERSION}")
    if(${MACOS_VERSION} STREQUAL "10.15")
      file(WRITE ${CMAKE_BINARY_DIR}/.spack/darwin/packages.yaml "packages:\n\
  libiconv:\n\
    paths:\n\
      libiconv@1.16%${SPACK_CLANG_INFO} arch=darwin-macos-x86_64: /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr")
    elseif(${MACOS_VERSION} STREQUAL "10.14")
      file(WRITE ${CMAKE_BINARY_DIR}/.spack/darwin/packages.yaml "packages:\n\
  libiconv:\n\
    paths:\n\
      libiconv@1.16%${SPACK_CLANG_INFO} arch=darwin-mojave-x86_64: /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr\n\
  sqlite:\n\
    paths:\n\
      sqlite@3.28.0%${SPACK_CLANG_INFO}+fts~functions arch=darwin-mojave-x86_64: /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr")
    else()
      Message(WARNING "FairSoft was not tested on macOS ${MACOS_VERSION}.")
    endif()
  endif()

  # If not yet done - add fairsoft repo to spack
  execute_process(COMMAND ./spack/bin/spack repo list WORKING_DIRECTORY
      ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE SPACK_REPOS)
  string(FIND ${SPACK_REPOS} "${CMAKE_SOURCE_DIR}\n" POS_FOUND)
  if(${POS_FOUND} EQUAL -1)
    execute_process(COMMAND ./spack/bin/spack repo add ${CMAKE_SOURCE_DIR}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
  endif()

  execute_process(COMMAND mktemp -d
    OUTPUT_VARIABLE TEST_TARGETDIR
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  message(STATUS "Directory for this test run: ${TEST_TARGETDIR}")

  # Build ######################################################################

  # Install fairroot and dependencies
  #  add_custom_target(SpackBuild ALL ${CMAKE_SOURCE_DIR}/spack/bin/spack -C
  #      ${CMAKE_BINARY_DIR}/.spack install fairsoft)

  add_custom_target(fairmq ${CMAKE_SOURCE_DIR}/spack/bin/spack -C
      ${CMAKE_BINARY_DIR}/.spack install fairmq)

  add_custom_target(fairsoft_nosim_nopython ${CMAKE_SOURCE_DIR}/spack/bin/spack -C
      ${CMAKE_BINARY_DIR}/.spack install fairroot@18.2.1~sim~python)

  add_custom_target(fairsoft_nosim_python ${CMAKE_SOURCE_DIR}/spack/bin/spack -C
      ${CMAKE_BINARY_DIR}/.spack install fairroot@18.2.1~sim+python)

  add_custom_target(fairsoft_python ${CMAKE_SOURCE_DIR}/spack/bin/spack -C
      ${CMAKE_BINARY_DIR}/.spack install fairroot@18.2.1+sim+python~g4mt)

  add_custom_target(fairsoft_g4mt_python ${CMAKE_SOURCE_DIR}/spack/bin/spack -C
      ${CMAKE_BINARY_DIR}/.spack install fairroot@18.2.1+sim+python+g4mt)

  add_custom_target(fairsoft_nopython ${CMAKE_SOURCE_DIR}/spack/bin/spack -C
      ${CMAKE_BINARY_DIR}/.spack install fairroot@18.2.1+sim~python~g4mt)

  add_custom_target(fairsoft_g4mt_nopython ${CMAKE_SOURCE_DIR}/spack/bin/spack -C
      ${CMAKE_BINARY_DIR}/.spack install fairroot@18.2.1+sim~python+g4mt)

  add_custom_target(clean_all ${CMAKE_SOURCE_DIR}/spack/bin/spack -C
      ${CMAKE_BINARY_DIR}/.spack uninstall --all --dependents fairroot@18.2.1)

  # Generate fairsoft-config script
  Configure_File(${CMAKE_SOURCE_DIR}/cmake/fairsoft-config.in
      ${CMAKE_BINARY_DIR}/fairsoft/bin/fairsoft-config @ONLY)

  # Install ####################################################################

  # Put links to all packages into one installation folder
  install(DIRECTORY ${CMAKE_SOURCE_DIR}/spack DESTINATION ${CMAKE_INSTALL_PREFIX} MESSAGE_NEVER)

  install(DIRECTORY ${CMAKE_BINARY_DIR}/.spack DESTINATION ${CMAKE_INSTALL_PREFIX})

  install(CODE "execute_process(COMMAND rm -rf ${CMAKE_INSTALL_PREFIX}/fairsoft WORKING_DIRECTORY ${CMAKE_BINARY_DIR})")

  install(PROGRAMS ${CMAKE_BINARY_DIR}/fairsoft/bin/fairsoft-config DESTINATION ${CMAKE_INSTALL_PREFIX}/fairsoft/bin)

  install(CODE "execute_process(COMMAND ./spack/bin/spack -C \
${CMAKE_BINARY_DIR}/.spack view --verbose --dependencies yes \
--exclude fairroot \
symlink -i ${CMAKE_INSTALL_PREFIX}/fairsoft \
fairroot@18.2.1 WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})")


  # Test #######################################################################

  macro(fs_test_props testname)
    set_property(TEST ${testname} APPEND PROPERTY ENVIRONMENT
                 TARGETDIR=${TEST_TARGETDIR})
  endmacro()
  function(fs_test_simple)
    cmake_parse_arguments(ARGS "" "NAME" "SPEC" ${ARGN})
    add_test(NAME simple.${ARGS_NAME}
             COMMAND test/buildsimple.sh ${ARGS_SPEC}
             WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
    fs_test_props(simple.${ARGS_NAME})
  endfunction()
  function(fs_test_env)
    cmake_parse_arguments(ARGS "" "NAME;ENVFILE" "" ${ARGN})
    add_test(NAME env.${ARGS_NAME}
             COMMAND test/buildenv.sh ${ARGS_ENVFILE}
             WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
    fs_test_props(env.${ARGS_NAME})
  endfunction()

  fs_test_simple(NAME openssl SPEC openssl)
  fs_test_simple(NAME bzip2 SPEC bzip2)

  fs_test_env(NAME fairlogger ENVFILE env/dev/fairlogger.yaml)
  fs_test_env(NAME dds        ENVFILE env/dev/dds.yaml)
  fs_test_env(NAME fairmq     ENVFILE env/dev/fairmq.yaml)
  fs_test_env(NAME jun19.threads   ENVFILE env/jun19/sim_threads.yaml)
  fs_test_env(NAME jun19.nothreads ENVFILE env/jun19/sim_no-threads.yaml)

# set(SPACK_DIR $ENV{SPACK_DIR})
# set(FAIRROOT_VERSION $ENV{FAIRROOT_VERSION})
# set(SPACK_EXTRA_FLAGS $ENV{SPACK_EXTRA_FLAGS})
#
# configure_file(${CMAKE_SOURCE_DIR}/test/cmaketest.sh.in ${CMAKE_BINARY_DIR}/test/cmaketest.sh)
# add_test(NAME build_fairroot_spack COMMAND ${CMAKE_BINARY_DIR}/test/cmaketest.sh)
# set_tests_properties(build_fairroot_spack PROPERTIES TIMEOUT 14400)
elseif(BUILD_METHOD STREQUAL legacy)
  # LEGACY MODE ################################################################
  # Former files in the FairSoft root directory have been moved to /legacy. This
  # mode copies all those files to the build directory (to support proper
  # out-of-source builds), generates a config file and invokes the legacy
  # configure.sh script.

  # Configure ##################################################################
  file(COPY legacy DESTINATION ${CMAKE_BINARY_DIR})
  configure_file(cmake/legacy.conf.in legacy/generated.conf @ONLY)

  # Build ######################################################################
  add_custom_target(LegacyBuild ALL
    ./configure.sh generated.conf
    COMMAND ${CMAKE_COMMAND} -E touch .installed
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/legacy
    COMMENT "Building and installing FairSoft via legacy shell scripts to ${CMAKE_INSTALL_PREFIX}"
    VERBATIM)

  # Install ####################################################################
  # We need a dummy install rule to create the global cmake install target
  install(FILES .installed DESTINATION ${CMAKE_INSTALL_PREFIX})

  # Test #######################################################################
  # TODO add_test(...) specific to legacy build
else()
  message(FATAL_ERROR "Unknown BUILD_METHOD=${BUILD_METHOD}. Must be either spack, or legacy.")
endif()

# Test #######################################################################
# TODO add_test(...) common to both builds
