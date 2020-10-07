################################################################################
#    Copyright (C) 2020 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH    #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################
find_package(Git REQUIRED)
find_package(Patch REQUIRED)
set(patch $<TARGET_FILE:Patch::patch> -N)

if(NOT DEFINED CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE RelWithDebInfo)
endif()
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 14)
endif()
if(NOT DEFINED NCPUS)
  include(ProcessorCount)
  ProcessorCount(NCPUS)
  if(NCPUS EQUAL 0)
    set(NCPUS 1)
  endif()
endif()
if(NOT PACKAGES)
  set(PACKAGES full)
endif()

include(ExternalProject)

set_property(DIRECTORY PROPERTY EP_BASE ${CMAKE_BINARY_DIR})
set_property(DIRECTORY PROPERTY EP_UPDATE_DISCONNECTED ON)
set(CMAKE_DEFAULT_ARGS CMAKE_CACHE_DEFAULT_ARGS
  "-DBUILD_SHARED:BOOL=ON"
  "-DCMAKE_PREFIX_PATH:STRING=${CMAKE_INSTALL_PREFIX}"
  "-DCMAKE_INSTALL_PREFIX:STRING=${CMAKE_INSTALL_PREFIX}"
  "-DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON"
  "-DCMAKE_CXX_STANDARD_REQUIRED:BOOL=ON"
  "-DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD}"
  "-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}"
  "-DCMAKE_INSTALL_LIBDIR:PATH=lib"
)
if(APPLE)
  set(CMAKE_DEFAULT_ARGS ${CMAKE_DEFAULT_ARGS}
    "-DCMAKE_MACOSX_RPATH:BOOL=ON"
  )
endif()
set(LOG_TO_FILE
  LOG_DIR "${CMAKE_BINARY_DIR}/Log"
  LOG_DOWNLOAD ON
  LOG_UPDATE ON
  LOG_PATCH ON
  LOG_CONFIGURE ON
  LOG_BUILD ON
  LOG_INSTALL ON
  LOG_TEST ON
  LOG_MERGED_STDOUTERR ON
  LOG_OUTPUT_ON_FAILURE ON
)

set(boost_version 72)
ExternalProject_Add(boost
  URL "https://dl.bintray.com/boostorg/release/1.${boost_version}.0/source/boost_1_${boost_version}_0.tar.bz2"
  URL_HASH SHA256=59c9b274bc451cf91a9ba1dd2c7fdcaf5d60b1b3aa83f2c9fa143417cc660722
  BUILD_IN_SOURCE ON
  CONFIGURE_COMMAND "./bootstrap.sh"
    "--prefix=${CMAKE_INSTALL_PREFIX}"
    "--without-libraries=python"
  PATCH_COMMAND ${patch} -p2 -i "${CMAKE_SOURCE_DIR}/legacy/boost/1.72_boost_process.patch"
  BUILD_COMMAND "./b2" "--layout=system"
    "cxxstd=${CMAKE_CXX_STANDARD}"
    "link=shared"
    "threading=multi"
    "variant=release"
    "visibility=hidden"
  INSTALL_COMMAND "./b2" "install" "-j" "${NCPUS}"
  ${LOG_TO_FILE}
)

set(fmt_version "6.1.2")
ExternalProject_Add(fmt
  URL "https://github.com/fmtlib/fmt/releases/download/${fmt_version}/fmt-${fmt_version}.zip"
  URL_HASH SHA256=63650f3c39a96371f5810c4e41d6f9b0bb10305064e6faf201cbafe297ea30e8
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DFMT_DOC=OFF"
  ${LOG_TO_FILE}
)

ExternalProject_Add(dds
  GIT_REPOSITORY https://github.com/FairRootGroup/DDS GIT_TAG 3.5.2
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DBoost_NO_BOOST_CMAKE=ON"
  PATCH_COMMAND ${patch} -p1 -i "${CMAKE_SOURCE_DIR}/legacy/dds/fix_boost_lookup.patch"
  BUILD_COMMAND ${CMAKE_COMMAND} --build . -j "${NCPUS}"
        COMMAND ${CMAKE_COMMAND} --build . --target wn_bin -j "${NCPUS}"
  DEPENDS boost
  ${LOG_TO_FILE}
)

ExternalProject_Add(fairlogger
  GIT_REPOSITORY https://github.com/FairRootGroup/FairLogger GIT_TAG v1.8.0
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DUSE_EXTERNAL_FMT=ON"
  DEPENDS boost fmt
  ${LOG_TO_FILE}
)

ExternalProject_Add(zeromq
  GIT_REPOSITORY https://github.com/zeromq/libzmq GIT_TAG v4.3.1
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DWITH_PERF_TOOL=ON"
    "-DZMQ_BUILD_TESTS=ON"
    "-DENABLE_CPACK=OFF"
  ${LOG_TO_FILE}
)

ExternalProject_Add(flatbuffers
  GIT_REPOSITORY https://github.com/google/flatbuffers GIT_TAG v1.12.0
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DFLATBUFFERS_BUILD_SHAREDLIB=ON"
    "-DFLATBUFFERS_BUILD_FLATLIB=OFF"
  PATCH_COMMAND ${patch} -p1 -i "${CMAKE_SOURCE_DIR}/legacy/flatbuffers/remove_werror.patch"
  ${LOG_TO_FILE}
)

if (NOT PACKAGES STREQUAL fairmqdev)
  ExternalProject_Add(fairmq
    GIT_REPOSITORY https://github.com/FairRootGroup/FairMQ GIT_TAG v1.4.25
    ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
      "-DBUILD_DDS_PLUGIN=ON"
      "-DBUILD_SDK_COMMANDS=ON"
      "-DBUILD_SDK=ON"
    DEPENDS boost dds fairlogger flatbuffers zeromq
  ${LOG_TO_FILE}
  )
endif()

if(PACKAGES STREQUAL full)
  set(pythia6_version "428-alice1")
  ExternalProject_Add(pythia6
    URL https://github.com/alisw/pythia6/archive/${pythia6_version}.tar.gz
    URL_HASH SHA256=b14e82870d3aa33d6fa07f4b1f4d17f1ab80a37d753f91ca6322352b397cb244
    PATCH_COMMAND ${patch} -p1 -i "${CMAKE_SOURCE_DIR}/legacy/pythia6/add_missing_extern_keyword.patch"
    ${CMAKE_DEFAULT_ARGS} ${LOG_TO_FILE}
  )

  set(hepmc_version 2.06.09)
  ExternalProject_Add(hepmc
    URL http://hepmc.web.cern.ch/hepmc/releases/hepmc${hepmc_version}.tgz
    URL_HASH SHA256=e0f8fddd38472c5615210894444686ac5d72df3be682f7d151b562b236d9b422
    ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
      "-Dlength:STRING=CM"
      "-Dmomentum:STRING=GEV"
    ${LOG_TO_FILE}
  )

  set(vc_version 1.4.1)
  ExternalProject_Add(vc
    URL https://github.com/VcDevel/Vc/archive/${vc_version}.tar.gz
    URL_HASH SHA256=7e8b57ed5ff9eb0835636203898c21302733973ff8eaede5134dd7cb87f915f6
    ${CMAKE_DEFAULT_ARGS} ${LOG_TO_FILE}
  )
endif()

include(CTest)

add_test(NAME test1
         COMMAND du -hs .
         WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
