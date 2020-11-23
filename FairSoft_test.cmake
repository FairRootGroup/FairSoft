################################################################################
#    Copyright (C) 2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH    #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################

message(STATUS " Starting CTest script : FairSoft_test.cmake")
message(STATUS " CMake Version ........: ${CMAKE_VERSION}")


# Set some default values, etc.
set(CTEST_TEST_TIMEOUT 14400)
set(CTEST_CUSTOM_MAXIMUM_PASSED_TEST_OUTPUT_SIZE 204800)
set(CTEST_CUSTOM_MAXIMUM_FAILED_TEST_OUTPUT_SIZE 409600)
set(CTEST_USE_LAUNCHERS ON)
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
if(NOT CTEST_BUILD_CONFIGURATION)
  set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)
endif()
if(NOT NCPUS)
  if(ENV{SLURM_CPUS_PER_TASK})
    set(NCPUS $ENV{SLURM_CPUS_PER_TASK})
  else()
    include(ProcessorCount)
    ProcessorCount(NCPUS)
    if(NCPUS EQUAL 0)
      set(NCPUS 1)
    endif()
  endif()
endif()
if(NOT BUILD_METHOD)
  set(BUILD_METHOD legacy)
endif()
message(STATUS " NCPUS ................: ${NCPUS}")

cmake_host_system_information(RESULT fqdn QUERY FQDN)
message(STATUS " Running on host ......: ${fqdn}")


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

    set(CTEST_BINARY_DIRECTORY "${FS_TEST_WORKDIR}/build")
else()
    # No temporary directory created
    set(FS_TEST_WORKDIR "")
    set(CTEST_SOURCE_DIRECTORY .)
    set(CTEST_BINARY_DIRECTORY build)
endif()

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
  # Make a note, which SHA-1 is going to modify the install tree:
  file(APPEND "${FS_TEST_INSTALLTREE}/sha1-stamps" "${FS_GIT_SHA}\n")
endif()

if ("$ENV{CTEST_SITE}" STREQUAL "")
  set(CTEST_SITE "${fqdn}")
else()
  set(CTEST_SITE $ENV{CTEST_SITE})
endif()

find_program(LSB_RELEASE_EXEC lsb_release)
if(NOT LSB_RELEASE_EXEC)
  message(WARNING "lsb_release not found")
  cmake_host_system_information(RESULT os_name QUERY OS_NAME)
  cmake_host_system_information(RESULT os_release QUERY OS_RELEASE)
else()
  execute_process(COMMAND ${LSB_RELEASE_EXEC} -si
    OUTPUT_VARIABLE os_name
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  execute_process(COMMAND ${LSB_RELEASE_EXEC} -sr
    OUTPUT_VARIABLE os_release
    OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
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

message(STATUS " BRANCH_NAME ..........: $ENV{BRANCH_NAME}")
message(STATUS " CHANGE_ID ............: $ENV{CHANGE_ID}")
message(STATUS " CHANGE_TARGET ........: $ENV{CHANGE_TARGET}")
set(cdash_group "Experimental")
if (NOT "$ENV{BRANCH_NAME}" STREQUAL "")
    set(cdash_group "Continuous")
    if ("$ENV{CHANGE_ID}" STREQUAL "")
        set(cdash_group "Nightly")
    endif()
endif()
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
  list(JOIN options ";" optionsstr)
  ctest_configure(OPTIONS "${optionsstr}")
  ctest_submit()
  ctest_build(FLAGS "-j${NCPUS}")
  ctest_submit()

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
  file(REMOVE_RECURSE "${FS_TEST_WORKDIR}")

  ctest_start(Continuous TRACK ${cdash_group})
  ctest_configure(OPTIONS "-DFS_TEST_WORKDIR=${FS_TEST_WORKDIR};-DFS_TEST_INSTALLTREE=${FS_TEST_INSTALLTREE};-DBUILD_METHOD=spack")
endif()
ctest_test(RETURN_VALUE _ctest_test_ret_val PARALLEL_LEVEL 3)
ctest_submit()

if (NOT BUILD_METHOD STREQUAL legacy)
  if (NOT _ctest_test_ret_val)
      # When we're here, then the complete build was successful.
      # So the install-tree represents a clean build for the
      # current SHA1:
      file(WRITE "${FS_TEST_INSTALLTREE}/sha1-stamps" "${FS_GIT_SHA}\n")
  endif()
endif()

if (NOT "${FS_TEST_WORKDIR_TEMP}" STREQUAL "")
    string(TIMESTAMP timestamp "[%H:%M:%S]")
    message(STATUS "${timestamp} Removing directory: ${FS_TEST_WORKDIR_TEMP}")
    file(REMOVE_RECURSE "${FS_TEST_WORKDIR_TEMP}")
endif()

if (_ctest_test_ret_val)
  Message(FATAL_ERROR "Some tests failed.")
endif()
