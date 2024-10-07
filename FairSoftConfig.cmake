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
set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/install" CACHE PATH "Install prefix")
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

#
# LZMA and ZSTD
#
# On macOS both packages aren't installed in some standard system path
# so we need to give CMake some hints where to find them.
# On Linux the packages are in the default system paths and are found
# automatically.
if(APPLE)
  execute_process(COMMAND brew --prefix OUTPUT_VARIABLE brew_prefix)
  set(LibLZMA_ROOT ${brew_prefix})
  set(ZSTD_ROOT ${brew_prefix})
endif()
