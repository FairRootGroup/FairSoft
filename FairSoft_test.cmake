################################################################################
#    Copyright (C) 2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH    #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################

message(STATUS " Starting CTest script : FairSoft_test.cmake")
message(STATUS " CMake Version ........: ${CMAKE_VERSION}")

if (USE_TEMPDIR)
    execute_process(COMMAND mktemp -d --tmpdir fairsoft_ctest.XXXXXX
                    OUTPUT_VARIABLE FS_TEST_WORKDIR
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    RESULT_VARIABLE res)
    if (res)
        execute_process(COMMAND mktemp -d
                        OUTPUT_VARIABLE FS_TEST_WORKDIR
                        OUTPUT_STRIP_TRAILING_WHITESPACE
                        RESULT_VARIABLE res)
    endif()
    if (res)
        message(FATAL_ERROR "Temp dir creation failed: ${res}")
    endif()
    message(STATUS " CTest workdir ........: ${FS_TEST_WORKDIR}")
else()
    set(FS_TEST_WORKDIR "")
endif()

if ("${FS_TEST_WORKDIR}" STREQUAL "")
    set(CTEST_SOURCE_DIRECTORY .)
else()
    set(CTEST_SOURCE_DIRECTORY "${FS_TEST_WORKDIR}/FairSoft")
    message(STATUS " Relocating to ........: ${CTEST_SOURCE_DIRECTORY}")

    string(TIMESTAMP timestamp "[%H:%M:%S]")
    message(STATUS "${timestamp} Copying ...")

    file(COPY . DESTINATION "${CTEST_SOURCE_DIRECTORY}")

    string(TIMESTAMP timestamp "[%H:%M:%S]")
    message(STATUS "${timestamp} ... done")
endif()

set(CTEST_BINARY_DIRECTORY build)
set(CTEST_TEST_TIMEOUT 10800)
set(CTEST_CUSTOM_MAXIMUM_PASSED_TEST_OUTPUT_SIZE 204800)
set(CTEST_USE_LAUNCHERS ON)
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
cmake_host_system_information(RESULT fqdn QUERY FQDN)

message(STATUS " Running on host ......: ${fqdn}")
if ("$ENV{CTEST_SITE}" STREQUAL "")
  set(CTEST_SITE "${fqdn}")
else()
  set(CTEST_SITE $ENV{CTEST_SITE})
endif()

if ("$ENV{LABEL}" STREQUAL "")
    find_program(LSB_RELEASE_EXEC lsb_release)
    if(NOT LSB_RELEASE_EXEC)
        message(WARNING "lsb_release not found")
        cmake_host_system_information(RESULT os_name QUERY OS_NAME)
        cmake_host_system_information(RESULT os_release QUERY OS_RELEASE)
        set(ENV{LABEL} "${os_name} ${os_release}")
    else()
        execute_process(COMMAND ${LSB_RELEASE_EXEC} -si
            OUTPUT_VARIABLE LSB_DIST_ID
            OUTPUT_STRIP_TRAILING_WHITESPACE)
        execute_process(COMMAND ${LSB_RELEASE_EXEC} -sr
            OUTPUT_VARIABLE LSB_DIST_RELEASE
            OUTPUT_STRIP_TRAILING_WHITESPACE)
        set(ENV{LABEL} "${LSB_DIST_ID} ${LSB_DIST_RELEASE}")
    endif()
endif()
set(CTEST_BUILD_NAME $ENV{LABEL})
if (NOT "$ENV{JOB_BASE_NAME}" STREQUAL "")
    set(CTEST_BUILD_NAME "$ENV{JOB_BASE_NAME} ${CTEST_BUILD_NAME}")
endif()

message(STATUS " BRANCH_NAME ..........: $ENV{BRANCH_NAME}")
message(STATUS " CHANGE_ID ............: $ENV{CHANGE_ID}")
set(cdash_group "Experimental")
if (NOT "$ENV{BRANCH_NAME}" STREQUAL "")
    set(cdash_group "Continuous")
    if ("$ENV{CHANGE_ID}" STREQUAL "")
        set(cdash_group "Nightly")
    endif()
endif()
message(STATUS " cdash_group ..........: ${cdash_group}")


# The cache contains the name of the source directory.
# As we might create a temporary source directory, this does
# not any more match. So remove the cache before start / configure.
file(REMOVE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt")
# ctest_empty_binary_directory("${CTEST_BINARY_DIRECTORY}")

ctest_start(Continuous TRACK ${cdash_group})
ctest_configure(OPTIONS "-DFS_TEST_WORKDIR=${FS_TEST_WORKDIR}")
# ctest_submit(PARTS Start Configure)

# ctest_build()
ctest_test(RETURN_VALUE _ctest_test_ret_val PARALLEL_LEVEL 3)
ctest_submit()

if (NOT "${FS_TEST_WORKDIR}" STREQUAL "")
    string(TIMESTAMP timestamp "[%H:%M:%S]")
    message(STATUS "${timestamp} Removing directory: ${FS_TEST_WORKDIR}")
    file(REMOVE_RECURSE "${FS_TEST_WORKDIR}")
endif()

if (_ctest_test_ret_val)
  Message(FATAL_ERROR "Some tests failed.")
endif()
