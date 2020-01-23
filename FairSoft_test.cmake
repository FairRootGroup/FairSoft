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
cmake_host_system_information(RESULT fqdn QUERY FQDN)
message(STATUS "Running on host: ${fqdn}")
if ("$ENV{CTEST_SITE}" STREQUAL "")
  set(CTEST_SITE "${fqdn}")
else()
  set(CTEST_SITE $ENV{CTEST_SITE})
endif()
set(CTEST_BUILD_NAME $ENV{LABEL})
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")

ctest_start(Continuous)
ctest_configure()
# ctest_build()
ctest_test(RETURN_VALUE _ctest_test_ret_val)
ctest_submit()

if (_ctest_test_ret_val)
  Message(FATAL_ERROR "Some tests failed.")
endif()
