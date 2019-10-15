################################################################################
#    Copyright (C) 2019 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH    #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################

include(CTest)

set(CTEST_SOURCE_DIRECTORY .)
set(CTEST_BINARY_DIRECTORY build)
set(CTEST_USE_LAUNCHERS ON)
set(CTEST_SUBMIT_URL "https://cdash.gsi.de/submit.php?project=FairSoft")
cmake_host_system_information(RESULT fqdn QUERY FQDN)
set(CTEST_SITE "${fqdn}")
set(CTEST_BUILD_NAME $ENV{LABEL})
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")

ctest_start(Continuous)
ctest_configure()
ctest_build()
ctest_test()
ctest_submit()
