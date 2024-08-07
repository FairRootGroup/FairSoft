################################################################################
# Copyright (C) 2019-2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH  #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################
if(CMAKE_BINARY_DIR STREQUAL CMAKE_SOURCE_DIR)
  message(FATAL_ERROR "In-source builds are not supported.")
endif()

cmake_minimum_required(VERSION 3.5...3.28 FATAL_ERROR)

if(APPLE)
  if(NOT DEFINED CMAKE_C_COMPILER)
    set(CMAKE_C_COMPILER clang)
  endif()
  if(NOT DEFINED CMAKE_CXX_COMPILER)
    set(CMAKE_CXX_COMPILER clang++)
  endif()
endif()

project(FairSoft LANGUAGES C CXX Fortran)
string(TOLOWER "${PROJECT_NAME}" PROJECT_NAME_LOWER)

if(NOT DEFINED BUILD_METHOD)
  set(BUILD_METHOD legacy)
endif()

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

include(${BUILD_METHOD})

find_program(BASH bash HINTS "/bin")
find_program(APPTAINER apptainer)
if(BASH AND APPTAINER)
  add_subdirectory(test/container)
endif()
