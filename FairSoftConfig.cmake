#
# General usage
#
# cmake -S <source-dir> -B <build-dir> -C <source-dir>/BuildConfig.cmake
# cmake --build <build-dir> [-j<ncpus>]
#

# In the following uncomment/change the appropriate option to your needs. You may copy
# this file and save under different names to

#
# Install prefix
#
#  Where to install the packages contained in FairSoft. FairRoot may find this FairSoft
#  via the environment variable SIMPATH.
#
set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/install" CACHE PATH "Install prefix" FORCE)
# set(CMAKE_INSTALL_PREFIX "/some/other/path" CACHE PATH "Install prefix" FORCE)

# Note: In the following, defaults are effective even if the option
#       is not set explicitely in this file.

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
# Package set
#
#  Which packages to build and install, choices are:
#  * full - All packages (default)
#  * fairmq - Only FairMQ and dependencies
#  * fairmqdev - Only development dependencies of FairMQ
#
# set(PACKAGE_SET "full" CACHE STRING "FairSoft package set" FORCE)
# set(PACKAGE_SET "fairmq" CACHE STRING "FairSoft package set" FORCE)
# set(PACKAGE_SET "fairmqdev" CACHE STRING "FairSoft package set" FORCE)

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
  execute_process(COMMAND brew --prefix python
                  OUTPUT_VARIABLE python_prefix)
  string(STRIP "${python_prefix}" python_prefix)
  set(PYTHON_EXECUTABLE "${python_prefix}/bin/python3" CACHE FILEPATH "Python executable" FORCE)
endif()
# set(PYTHON_EXECUTABLE "/some/other/path/to/python" CACHE FILEPATH "Python executable" FORCE)
