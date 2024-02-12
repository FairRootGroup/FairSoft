################################################################################
# Copyright (C) 2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH       #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################
#[=======================================================================[
FindZSTD
-----------

Find ZSTD compression algorithm headers and library.

Result variables
^^^^^^^^^^^^^^^^

This module will set the following variables in your project:

``ZSTD_FOUND``
  True if libzstd headers and library were found.
``ZSTD_INCLUDE_DIR``
  Directory where libzstd headers are located.
``ZSTD_LIBRARY``
  Zstd library to link against.
``ZSTD_BINARY``
  Zstd binary
``ZSTD_VERSION``
    the version of ZSTD found.
#]=======================================================================]

find_path(ZSTD_INCLUDE_DIR zstd.h)

if(NOT ZSTD_LIBRARY)
  find_library(ZSTD_LIBRARY NAMES zstd lzstd libzstd NAMES_PER_DIR PATH_SUFFIXES lib)
endif()

if(NOT ZSTD_BINARY)
  find_program(ZSTD_BINARY NAMES zstd NAMES_PER_DIR PATH_SUFFIXES bin)
endif()

if(ZSTD_BINARY)
  execute_process(COMMAND ${ZSTD_BINARY} --version
                    OUTPUT_VARIABLE zstd_version
                   )
  string(REGEX REPLACE "^.*([0-9]\\.[0-9]\\.[0-9])+.*" "\\1" zstd_version1 "${zstd_version}")
  set(ZSTD_VERSION "${zstd_version1}" CACHE STRING "ZSTD version info for Boost" FORCE)
elseif(ZSTD_INCLUDE_DIR)
  file(READ ${ZSTD_INCLUDE_DIR}/zstd.h ZSTD_VERSION_INFO)
  string(REGEX REPLACE ".*#define[ ]+ZSTD_VERSION_MAJOR[ ]+([0-9]+).*" "\\1" ZSTD_VERSION_MAJOR "${ZSTD_VERSION_INFO}")
  string(REGEX REPLACE ".*#define[ ]+ZSTD_VERSION_MINOR[ ]+([0-9]+).*" "\\1" ZSTD_VERSION_MINOR "${ZSTD_VERSION_INFO}")
  string(REGEX REPLACE ".*#define[ ]+ZSTD_VERSION_RELEASE[ ]+([0-9]+).*" "\\1" ZSTD_VERSION_RELEASE "${ZSTD_VERSION_INFO}")
  set(ZSTD_VERSION "${ZSTD_VERSION_MAJOR}.${ZSTD_VERSION_MINOR}.${ZSTD_VERSION_RELEASE}" CACHE STRING "ZSTD version info for Boost" FORCE)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ZSTD  REQUIRED_VARS  ZSTD_LIBRARY
                                                       ZSTD_INCLUDE_DIR
                                        VERSION_VAR    ZSTD_VERSION
                                 )
mark_as_advanced( ZSTD_INCLUDE_DIR ZSTD_LIBRARY )
