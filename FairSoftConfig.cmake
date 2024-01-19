#
# General usage
#
# cmake -S <source-dir> -B <build-dir> -C <source-dir>/FairSoftConfig.cmake
# cmake --build <build-dir> [-j<ncpus>]
#

# In the following uncomment/change the appropriate option to your needs. Manage multiple
# configurations by simply copying this file under different filenames.

#
# Install prefix
#
#  Where to install the packages contained in FairSoft. FairRoot may find this FairSoft
#  via the environment variable SIMPATH.
#
set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/install" CACHE PATH "Install prefix" FORCE)
# set(CMAKE_INSTALL_PREFIX "/some/other/path" CACHE PATH "Install prefix" FORCE)

# Note: Defaults are effective even if the option is not set explicitely in this file.

#
# Build type
#
#  The CMake build type determines certain build flags, possible choices are:
#  * RelWithDebInfo - Optimized build with debug symbols (default)
#  * Release - Optimized build
#  * Debug - Unoptimized build with debug symbols and run-time assertions
#
# set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Build type" FORCE)
# set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type" FORCE)
# set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type" FORCE)

#
# Geant4 multi-threading (default OFF)
#
# set(GEANT4MT OFF CACHE BOOL "Build Geant4 in multi-threading mode" FORCE)
# set(GEANT4MT ON CACHE BOOL "Build Geant4 in multi-threading mode" FORCE)

#
# Python
#
#  On macOS we assume you have used <source-dir>/legacy/setup-macos.sh which
#  installs Python via Homebrew. That the Homebrew-based Python is chosen over the
#  native macOS Python we have to hint its location:
#
if(APPLE)
  execute_process(COMMAND brew --prefix python OUTPUT_VARIABLE python_prefix)
  string(STRIP "${python_prefix}" python_prefix)
  set(Python_EXECUTABLE "${python_prefix}/bin/python3" CACHE FILEPATH "Python executable" FORCE)
endif()
# set(Python_EXECUTABLE "/some/other/path/to/python" CACHE FILEPATH "Python executable" FORCE)

#
# ICU
#
#  On macOS we assume you have used <source-dir>/legacy/setup-macos.sh which
#  installs ICU via Homebrew. That the Homebrew-based ICU is chosen over the
#  native macOS ICU we have to hint its location:
#
if(APPLE)
  execute_process(COMMAND brew --prefix icu4c OUTPUT_VARIABLE icu_prefix)
  string(STRIP "${icu_prefix}" icu_prefix)
  set(ICU_ROOT "${icu_prefix}" CACHE FILEPATH "ICU prefix" FORCE)
endif()

#
# macOS SDK
#
#  On macOS building ROOT is picky about the chosen macOS SDK. The issue is not fully understood,
#  but it appears to work if one chooses the latest major version among the installed macOS SDKs.
#  If you experience that this default behaviour does not work out for you, please let us know!
#
#  `brew` contains some logic to detect installed SDKs on your machine and can choose the latest.
#  Since we anyways depend on brew, let's use it.
#
if(APPLE)
  execute_process(COMMAND brew ruby -e "puts MacOS.sdk_path" OUTPUT_VARIABLE macos_sdk_path)
  string(STRIP "${macos_sdk_path}" macos_sdk_path)
  set(CMAKE_OSX_SYSROOT "${macos_sdk_path}" CACHE FILEPATH "macOS SDK" FORCE)
endif()

if(APPLE)
  execute_process(COMMAND brew --prefix OUTPUT_VARIABLE brew_prefix)
endif()

#
# LZMA
#
# On macOS LZMA isn't installed in some standard system path
# so we need to take it from brew. The xz package which contains
# the needed headers and libraries is installed with the setup script
# from <source-dir>/legacy/setup-macos.sh.
# On Linux the packages are in the default system paths and are found
# automatically by Boost.
#
if(NOT ${brew_prefix} MATCHES "/usr/local")
  execute_process(COMMAND brew list xz RESULT_VARIABLE lzma_installed OUTPUT_VARIABLE _tmp)
  if (NOT lzma_installed)
    message(STATUS "LZMA installation found. Boost iostream will be build with lzma compression")
    execute_process(COMMAND brew --prefix xz OUTPUT_VARIABLE lzma_prefix)
    string(STRIP "${lzma_prefix}" lzma_prefix)
    set(LZMA_ROOT "${lzma_prefix}" CACHE FILEPATH "LZMA prefix" FORCE)
    execute_process(COMMAND ${LZMA_ROOT}/bin/xz --version
                    OUTPUT_VARIABLE lzma_version
                   )
    string(REGEX REPLACE ".*([0-9]\\.[0-9]\\.[0-9])+.*" "\\1" lzma_version1 ${lzma_version})
    set(LZMA_EXTERNAL "using lzma   :" CACHE STRING "LZMA exetrnal usage for Boost" FORCE)
    set(LZMA_VERSION "${lzma_version1}" CACHE STRING "LZMA version info for Boost" FORCE)
    set(LZMA_STRING ": <include>${LZMA_ROOT}/include <search>${LZMA_ROOT}/lib ;" CACHE STRING "LZMA install info for Boost" FORCE)
  else()
    message(WARNING "LZMA installation not found. Boost iostream will be build without lzma compression")
    set(LZMA_EXTERNAL "" CACHE STRING "LZMA exetrnal usage for Boost" FORCE)
    set(LZMA_VERSION "" CACHE STRING "LZMA version info for Boost" FORCE)
    set(LZMA_STRING "" CACHE STRING "LZMA install info for Boost" FORCE)
  endif()
else()
  set(LZMA_EXTERNAL "" CACHE STRING "LZMA exetrnal usage for Boost" FORCE)
  set(LZMA_VERSION "" CACHE STRING "LZMA version info for Boost" FORCE)
  set(LZMA_STRING "" CACHE STRING "LZMA install info for Boost" FORCE)
endif()

#
# ZSTD
#
# On macOS ZSTD isn't installed in some standard system path
# so we need to take it from brew. The zstd package which contains
# the needed headers and libraries is installed with the setup script
# from <source-dir>/legacy/setup-macos.sh.
# On Linux the packages are in the default system paths and are found
# automatically by Boost.
#
if(NOT ${brew_prefix} MATCHES "/usr/local")
  execute_process(COMMAND brew list zstd RESULT_VARIABLE zstd_installed OUTPUT_VARIABLE _tmp)
  if (NOT zstd_installed)
    message(STATUS "ZSTD installation found. Boost iostream will be build with zstd compression")
    execute_process(COMMAND brew --prefix zstd OUTPUT_VARIABLE zstd_prefix)
    string(STRIP "${zstd_prefix}" zstd_prefix)
    set(ZSTD_ROOT "${zstd_prefix}" CACHE FILEPATH "ZSTD prefix" FORCE)
    execute_process(COMMAND ${ZSTD_ROOT}/bin/zstd --version
                    OUTPUT_VARIABLE zstd_version
                   )
    string(REGEX REPLACE "^.*([0-9]\\.[0-9]\\.[0-9])+.*" "\\1" zstd_version1 "${zstd_version}")
    set(ZSTD_EXTERNAL "using zstd   :" CACHE STRING "ZSTD exetrnal usage for Boost" FORCE)
    set(ZSTD_VERSION "${zstd_version1}" CACHE STRING "ZSTD version info for Boost" FORCE)
    set(ZSTD_STRING ": <include>${ZSTD_ROOT}/include <search>${ZSTD_ROOT}/lib ;" CACHE STRING "ZSTD install info for Boost" FORCE)
  else()
    message(WARNING "ZSTD installation not found. Boost iostream will be build without zstd compression")
    set(ZSTD_EXTERNAL "" CACHE STRING "ZSTD exetrnal usage for Boost" FORCE)
    set(ZSTD_VERSION "" CACHE STRING "ZSTD version info for Boost" FORCE)
    set(ZSTD_STRING "" CACHE STRING "ZSTD install info for Boost" FORCE)
  endif()
else()
  set(ZSTD_EXTERNAL "" CACHE STRING "ZSTD exetrnal usage for Boost" FORCE)
  set(ZSTD_VERSION "" CACHE STRING "ZSTD version info for Boost" FORCE)
  set(ZSTD_STRING "" CACHE STRING "ZSTD install info for Boost" FORCE)
endif()
