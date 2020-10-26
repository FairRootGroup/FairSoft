################################################################################
# Copyright (C) 2019-2020 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH  #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################
if(CMAKE_BINARY_DIR STREQUAL CMAKE_SOURCE_DIR)
  message(FATAL_ERROR "In-source builds are not supported.")
endif()

cmake_minimum_required(VERSION 3.0 FATAL_ERROR)
cmake_policy(VERSION 3.0...3.18)

if(APPLE)
  if(NOT DEFINED CMAKE_C_COMPILER)
    set(CMAKE_C_COMPILER clang)
  endif()
  if(NOT DEFINED CMAKE_CXX_COMPILER)
    set(CMAKE_CXX_COMPILER clang++)
  endif()
endif()

project(FairSoft LANGUAGES C CXX Fortran)

if(NOT DEFINED BUILD_METHOD)
  set(BUILD_METHOD spack)
endif()

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

include(${BUILD_METHOD})
