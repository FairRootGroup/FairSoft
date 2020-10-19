################################################################################
#    Copyright (C) 2020 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH    #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################

# Defines some variables with console color escape sequences
if(NOT WIN32 AND NOT DISABLE_COLOR)
  string(ASCII 27 Esc)
  set(CR       "${Esc}[m")
  set(CB       "${Esc}[1m")
  set(Red      "${Esc}[31m")
  set(Green    "${Esc}[32m")
  set(Yellow   "${Esc}[33m")
  set(Blue     "${Esc}[34m")
  set(Magenta  "${Esc}[35m")
  set(Cyan     "${Esc}[36m")
  set(White    "${Esc}[37m")
  set(BRed     "${Esc}[1;31m")
  set(BGreen   "${Esc}[1;32m")
  set(BYellow  "${Esc}[1;33m")
  set(BBlue    "${Esc}[1;34m")
  set(BMagenta "${Esc}[1;35m")
  set(BCyan    "${Esc}[1;36m")
  set(BWhite   "${Esc}[1;37m")
endif()

function(pad str width char out)
  cmake_parse_arguments(ARGS "" "COLOR" "" ${ARGN})
  string(LENGTH ${str} length)
  if(ARGS_COLOR)
    math(EXPR padding "${width}-(${length}-10*${ARGS_COLOR})")
  else()
    math(EXPR padding "${width}-${length}")
  endif()
  if(padding GREATER 0)
    foreach(i RANGE ${padding})
      set(str "${str}${char}")
    endforeach()
  endif()
  set(${out} ${str} PARENT_SCOPE)
endfunction()

macro(set_fairsoft_defaults)
  # Configure build types
  set(CMAKE_CONFIGURATION_TYPES "Debug" "Release" "RelWithDebInfo")
  set(_warnings "-Wshadow -Wall -Wextra -Wpedantic")
  set(CMAKE_C_FLAGS_DEBUG                "-Og -g ${_warnings}")
  set(CMAKE_C_FLAGS_RELEASE              "-O2 -DNDEBUG")
  set(CMAKE_C_FLAGS_RELWITHDEBINFO       "-O2 -g ${_warnings} -DNDEBUG")
  set(CMAKE_CXX_FLAGS_DEBUG              "-Og -g ${_warnings}")
  set(CMAKE_CXX_FLAGS_RELEASE            "-O2 -DNDEBUG")
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO     "-O2 -g ${_warnings} -DNDEBUG")
  set(CMAKE_Fortran_FLAGS_DEBUG          "-Og -g ${_warnings}")
  set(CMAKE_Fortran_FLAGS_RELEASE        "-O2 -DNDEBUG")
  set(CMAKE_Fortran_FLAGS_RELWITHDEBINFO "-O2 -g ${_warnings} -DNDEBUG")
  unset(_warnings)

  # Set a default build type
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE RelWithDebInfo)
  endif()

  # Handle C++ standard level
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  if(NOT CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD ${PROJECT_MIN_CXX_STANDARD})
  elseif(${CMAKE_CXX_STANDARD} LESS ${PROJECT_MIN_CXX_STANDARD})
    message(FATAL_ERROR "A minimum CMAKE_CXX_STANDARD of ${PROJECT_MIN_CXX_STANDARD} is required.")
  endif()
  set(CMAKE_CXX_EXTENSIONS OFF)

  if(NOT BUILD_SHARED_LIBS)
    set(BUILD_SHARED_LIBS ON CACHE BOOL "Whether to build shared libraries or static archives")
  endif()

  # Set -fPIC as default for all library types
  if(NOT CMAKE_POSITION_INDEPENDENT_CODE)
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
  endif()

  # Generate compile_commands.json file (https://clang.llvm.org/docs/JSONCompilationDatabase.html)
  set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

  if(NOT DEFINED NCPUS)
    include(ProcessorCount)
    ProcessorCount(NCPUS)
    if(NCPUS EQUAL 0)
      set(NCPUS 1)
    endif()
  endif()
endmacro()
