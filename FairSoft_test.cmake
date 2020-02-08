################################################################################
#    Copyright (C) 2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH    #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################

set(CTEST_SOURCE_DIRECTORY .)
set(CTEST_BINARY_DIRECTORY build)
set(CTEST_TEST_TIMEOUT 10800)
set(CTEST_USE_LAUNCHERS ON)
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
cmake_host_system_information(RESULT fqdn QUERY FQDN)
cmake_host_system_information(RESULT os_name QUERY OS_NAME)
cmake_host_system_information(RESULT os_release QUERY OS_RELEASE)

message(STATUS "Running on host: ${fqdn}")
if ("$ENV{CTEST_SITE}" STREQUAL "")
  set(CTEST_SITE "${fqdn}")
else()
  set(CTEST_SITE $ENV{CTEST_SITE})
endif()

if ("$ENV{LABEL}" STREQUAL "")
    find_program(LSB_RELEASE_EXEC lsb_release)
    if(NOT LSB_RELEASE_EXEC)
        message(WARNING "lsb_release not found")
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
    set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME} $ENV{JOB_BASE_NAME}")
endif()

ctest_start(Continuous)
ctest_configure()
# ctest_build()
ctest_test(RETURN_VALUE _ctest_test_ret_val)
ctest_submit()

if (_ctest_test_ret_val)
  Message(FATAL_ERROR "Some tests failed.")
endif()
