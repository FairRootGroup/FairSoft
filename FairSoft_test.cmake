################################################################################
# Copyright (C) 2019-2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH  #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################

message(STATUS " Starting CTest script : FairSoft_test.cmake")
message(STATUS " CMake Version ........: ${CMAKE_VERSION}")

set(CMAKE_MODULE_PATH "cmake")
include(FairSoftLib)

# Set some default values, etc.
set(CTEST_TEST_TIMEOUT 14400)
set(CTEST_BINARY_DIRECTORY build)
set(CTEST_CUSTOM_MAXIMUM_PASSED_TEST_OUTPUT_SIZE 204800)
set(CTEST_CUSTOM_MAXIMUM_FAILED_TEST_OUTPUT_SIZE 409600)
set(CTEST_USE_LAUNCHERS ON)
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
if(NOT CTEST_BUILD_CONFIGURATION)
  set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)
endif()
if(NOT BUILD_METHOD)
  set(BUILD_METHOD legacy)
endif()
cmake_host_system_information(RESULT fqdn QUERY FQDN)
message(STATUS " Running on host ......: ${fqdn}")

get_NCPUS()
message(STATUS " NCPUS ................: ${NCPUS} (from ${NCPUS_SOURCE})")
set(ENV{SPACK_BUILD_JOBS} "${NCPUS}")

show_jenkins_info()

# Detect current git SHA
execute_process(COMMAND git rev-parse --verify HEAD
                OUTPUT_VARIABLE FS_GIT_SHA
                OUTPUT_STRIP_TRAILING_WHITESPACE)
message(STATUS " Git SHA-1 ............: ${FS_GIT_SHA}")


if (USE_TEMPDIR)
    if ("$ENV{BUILD_TAG}" STREQUAL "")
        set(tempdirspec "fairsoft_ctest.XXXXXX")
    else()
        set(tempdirspec "$ENV{BUILD_TAG}.XXX")
    endif()
    execute_process(COMMAND mktemp -d --tmpdir ${tempdirspec}
                    OUTPUT_VARIABLE FS_TEST_WORKDIR_TEMP
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    RESULT_VARIABLE res)
    if (res)
        execute_process(COMMAND mktemp -d
                        OUTPUT_VARIABLE FS_TEST_WORKDIR_TEMP
                        OUTPUT_STRIP_TRAILING_WHITESPACE
                        RESULT_VARIABLE res)
    endif()
    if (res)
        message(FATAL_ERROR "Temp dir creation failed: ${res}")
    endif()
    set(FS_TEST_WORKDIR "${FS_TEST_WORKDIR_TEMP}")
    message(STATUS " CTest workdir (temp) .: ${FS_TEST_WORKDIR}")

    # Relocate complete tree into temp directory

    set(CTEST_SOURCE_DIRECTORY "${FS_TEST_WORKDIR}/FairSoft")
    message(STATUS " Relocating to ........: ${CTEST_SOURCE_DIRECTORY}")

    string(TIMESTAMP timestamp "[%H:%M:%S]")
    message(STATUS "${timestamp} Copying ...")

    file(COPY . DESTINATION "${CTEST_SOURCE_DIRECTORY}")

    string(TIMESTAMP timestamp "[%H:%M:%S]")
    message(STATUS "${timestamp} ... done")

    if (BUILD_METHOD STREQUAL legacy)
        set(CTEST_BINARY_DIRECTORY "${FS_TEST_WORKDIR}/build")
    endif()
else()
    # No temporary directory created
    set(FS_TEST_WORKDIR "")
    set(CTEST_SOURCE_DIRECTORY .)
endif()
message(STATUS " CTEST_SOURCE_DIRECTORY: ${CTEST_SOURCE_DIRECTORY}")
message(STATUS " CTEST_BINARY_DIRECTORY: ${CTEST_BINARY_DIRECTORY}")

if (NOT BUILD_METHOD STREQUAL legacy)
  if ("${FS_TEST_INSTALLTREE}" STREQUAL "")
      if ("${FS_TEST_WORKDIR}" STREQUAL "")
          get_filename_component(FS_TEST_INSTALLTREE
                                 "${CTEST_BINARY_DIRECTORY}/install-tree"
                                 ABSOLUTE)
      else()
          set(FS_TEST_INSTALLTREE "${FS_TEST_WORKDIR}/install-tree")
      endif()
  endif()
  file(MAKE_DIRECTORY "${FS_TEST_INSTALLTREE}")
  file(LOCK "${FS_TEST_INSTALLTREE}" DIRECTORY TIMEOUT 300)
  message(STATUS " FS_TEST_INSTALLTREE ..: ${FS_TEST_INSTALLTREE}")
  # Make a note, which SHA-1 is going to modify the install tree:
  file(APPEND "${FS_TEST_INSTALLTREE}/sha1-stamps" "${FS_GIT_SHA}\n")
endif()

set(test_parallel_level 3)
if(DEFINED ENV{FS_TEST_PARALLEL_LEVEL})
    set(test_parallel_level "$ENV{FS_TEST_PARALLEL_LEVEL}")
endif()
message(STATUS " test_parallel_level ..: ${test_parallel_level}")
set(ENV{FS_TEST_PARALLEL_LEVEL} "${test_parallel_level}")

if ("$ENV{CTEST_SITE}" STREQUAL "")
  set(CTEST_SITE "${fqdn}")
else()
  set(CTEST_SITE $ENV{CTEST_SITE})
endif()

get_os_name_release()
if("$ENV{LABEL}" STREQUAL "")
  set(ENV{LABEL} "${os_name} ${os_release}")
endif()
set(CTEST_BUILD_NAME $ENV{LABEL})
if (NOT "$ENV{JOB_BASE_NAME}" STREQUAL "")
    set(CTEST_BUILD_NAME "$ENV{JOB_BASE_NAME} ${CTEST_BUILD_NAME}")
endif()
if (BUILD_METHOD STREQUAL legacy)
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME} (legacy)")
endif()

set(cdash_group "Experimental")
if (NOT "$ENV{BRANCH_NAME}" STREQUAL "")
    set(cdash_group "Continuous")
    if ("$ENV{CHANGE_ID}" STREQUAL "")
        set(cdash_group "Nightly")
    endif()
endif()

message(STATUS " CTEST_SITE ...........: ${CTEST_SITE}")
message(STATUS " CTEST_BUILD_NAME .....: ${CTEST_BUILD_NAME}")
message(STATUS " cdash_group ..........: ${cdash_group}")

if (BUILD_METHOD STREQUAL legacy)
  ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  file(REMOVE_RECURSE "${FS_TEST_WORKDIR}/install")
  file(REMOVE_RECURSE "logs")
  ctest_start(Continuous TRACK ${cdash_group})
  list(APPEND options
    "-DBUILD_METHOD=legacy"
    "-DCMAKE_INSTALL_PREFIX=install"
    "-DNCPUS=${NCPUS}")
  if(APPLE)
    execute_process(COMMAND brew --prefix python OUTPUT_VARIABLE python_prefix)
    string(STRIP "${python_prefix}" python_prefix)
    list(APPEND options "-DPython_EXECUTABLE=${python_prefix}/bin/python3")
    execute_process(COMMAND brew --prefix icu4c OUTPUT_VARIABLE icu_prefix)
    string(STRIP "${icu_prefix}" icu_prefix)
    list(APPEND options "-DICU_ROOT=${icu_prefix}")
  endif()
  list(JOIN options ";" optionsstr)
  show_big_header("Configuring")
  ctest_configure(OPTIONS "${optionsstr}")
  fairsoft_ctest_submit()

  show_big_header("Building")
  ctest_build(RETURN_VALUE _ctest_build_retval
              NUMBER_ERRORS _ctest_build_errors
              FLAGS "-j${NCPUS}")
  fairsoft_ctest_submit()
  if (_ctest_build_errors)
    set(_ctest_build_retval 255)
  endif()

  set(from "${CTEST_BINARY_DIRECTORY}/Log")
  message(STATUS " Copy logs ....... from: ${from}")
  set(to "logs/${os_name}-${os_release}")
  message(STATUS " ................... to: ${to}")
  string(TIMESTAMP timestamp "[%H:%M:%S]")
  message(STATUS "${timestamp} Copying ...")
  file(GLOB logs "${from}/*.log")
  file(COPY ${logs} DESTINATION "${to}")
  string(TIMESTAMP timestamp "[%H:%M:%S]")
  message(STATUS "${timestamp} ... done")
else()
  # Full cleaning:
  #  ctest_empty_binary_directory("${CTEST_BINARY_DIRECTORY}")
  #
  # The cache contains the name of the source directory.
  # As we might create a temporary source directory, this does
  # not any more match. So remove the cache before start / configure.
  file(REMOVE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt")
  # Remove workdir (keep in sync with CMakeLists.txt)
  file(REMOVE_RECURSE "${CTEST_BINARY_DIRECTORY}/test_workdir")

  ctest_start(Continuous TRACK ${cdash_group})
  show_big_header("Configuring")
  ctest_configure(OPTIONS "-DFS_TEST_WORKDIR=${FS_TEST_WORKDIR};-DFS_TEST_INSTALLTREE=${FS_TEST_INSTALLTREE};-DBUILD_METHOD=spack")
  set(_ctest_build_retval 0)
endif()
if (_ctest_build_retval)
    show_big_header("Skipping Tests, Build Failed")
    set(_ctest_test_ret_val 255)
else()
    show_big_header("Starting Tests")
    ctest_test(RETURN_VALUE _ctest_test_ret_val
               PARALLEL_LEVEL ${test_parallel_level})
endif()
fairsoft_ctest_submit(FINAL)

if (NOT "${FS_TEST_WORKDIR_TEMP}" STREQUAL "")
    string(TIMESTAMP timestamp "[%H:%M:%S]")
    message(STATUS "${timestamp} Removing directory: ${FS_TEST_WORKDIR_TEMP}")
    file(REMOVE_RECURSE "${FS_TEST_WORKDIR_TEMP}")
endif()

cdash_summary()

if (_ctest_test_ret_val)
  Message(FATAL_ERROR " \n"
          "   /!\\  Some tests failed.")
endif()
