################################################################################
# Copyright (C) 2019-2020 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH  #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################
# Update spack submodule
find_package(Git)
if(GIT_FOUND)
  execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
endif()

# Test #######################################################################
include(CTest)

if (DEFINED FS_TEST_WORKDIR AND NOT "${FS_TEST_WORKDIR}" STREQUAL "")
    message(STATUS "FS_TEST_WORKDIR: ${FS_TEST_WORKDIR}")
    if (EXISTS "${FS_TEST_WORKDIR}" AND IS_DIRECTORY "${FS_TEST_WORKDIR}")
        # Everything fine.
    else()
        message(FATAL_ERROR "If you set FS_TEST_WORKDIR, make sure, "
                "it is a directory")
    endif()
else()
    # Setup local workdir
    # (keep in sync with FairSoft_test.cmake)
    set(FS_TEST_WORKDIR "${CMAKE_BINARY_DIR}/test_workdir")
    file(MAKE_DIRECTORY "${FS_TEST_WORKDIR}")
    message(STATUS "Created directory for test run: ${FS_TEST_WORKDIR}")
endif()

macro(fs_test_might_fail testname)
  # If the test fails with exit code 1, mark it as skipped.
  # Not exactly, what we want, but hopefully better.
  set_property(TEST ${testname} APPEND PROPERTY
               SKIP_RETURN_CODE 1)
endmacro()
function(fs_test_props_base testname)
  set_property(TEST ${testname} APPEND PROPERTY ENVIRONMENT
               FS_TEST_WORKDIR=${FS_TEST_WORKDIR})
  set_property(TEST ${testname} APPEND PROPERTY ENVIRONMENT
               FS_TEST_INSTALLTREE=${FS_TEST_INSTALLTREE})
  set_property(TEST ${testname} APPEND PROPERTY ENVIRONMENT
               CMAKE_BINARY_DIR=${CMAKE_BINARY_DIR})
endfunction()
function(fs_test_props testname)
  fs_test_props_base(${testname})
  set_property(TEST ${testname} APPEND PROPERTY
               FIXTURES_REQUIRED fixture.main)
  set_property(TEST ${testname} APPEND PROPERTY
               TIMEOUT 14400)
endfunction()
function(fs_test)
  cmake_parse_arguments(ARGS "MIGHT_FAIL" "NAME;ENV;SPEC;POST" "DEPENDS" ${ARGN})
  if(ARGS_ENV)
    set(type env)
    set(what ${ARGS_ENV}/spack.yaml)
  elseif(ARGS_SPEC)
    set(type spec)
    set(what ${ARGS_SPEC})
  endif()
  add_test(NAME ${ARGS_NAME}
           COMMAND test/build${type}.sh ${what} ${ARGS_POST}
           WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
  fs_test_props(${ARGS_NAME})
  if(ARGS_MIGHT_FAIL)
    fs_test_might_fail(${ARGS_NAME})
  endif()
  if(ARGS_DEPENDS)
    set_property(TEST ${ARGS_NAME} APPEND PROPERTY
                 DEPENDS ${ARGS_DEPENDS})
  endif()
endfunction()


# Test setup
# ----------

add_test(NAME test.start
         COMMAND test/buildstart.sh
         WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
fs_test_props_base(test.start)
set_property(TEST test.start APPEND PROPERTY
             FIXTURES_SETUP fixture.main)


# Main tests
# ----------

fs_test(NAME test.cmake               SPEC cmake)
fs_test(NAME test.grpc                SPEC grpc)
fs_test(NAME test.flatbuffers         SPEC flatbuffers)
fs_test(NAME test.fairlogger          ENV test/env/fairlogger)
fs_test(NAME test.dds                 ENV test/env/dds)
fs_test(NAME test.fairmq              ENV test/env/fairmq)
fs_test(NAME test.odc                 SPEC odc)
fs_test(NAME jun19.sim                ENV env/jun19/sim)
fs_test(NAME jun19.sim_mt             ENV env/jun19/sim_mt)
fs_test(NAME dev.sim                  ENV env/dev/sim)
fs_test(NAME dev.sim_mt               ENV env/dev/sim_mt)
fs_test(NAME dev.sim_mt_headless      ENV env/dev/sim_mt_headless)
fs_test(NAME test.jun19_fairroot_18_4 ENV test/env/jun19_fairroot_18_4)
fs_test(NAME test.fairroot_develop    ENV test/env/fairroot_develop)
fs_test(NAME test.r3broot             ENV test/env/r3broot)

fs_test(NAME workflow.classic_developer_jun19
        ENV env/jun19/sim
        DEPENDS jun19.sim
        POST test/workflow/classic_developer.sh)
fs_test(NAME workflow.classic_developer_dev
        ENV env/dev/sim
        DEPENDS "dev.sim;workflow.classic_developer_jun19"
        POST test/workflow/classic_developer.sh)

# Test cleanup
# ------------

add_test(NAME test.cleanup
         COMMAND test/buildcleanup.sh
         WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
fs_test_props_base(test.cleanup)
set_property(TEST test.cleanup APPEND PROPERTY
             FIXTURES_CLEANUP fixture.main)
