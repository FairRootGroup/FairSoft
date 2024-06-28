################################################################################
# Copyright (C) 2020-2024 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH  #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################
cmake_minimum_required(VERSION 3.19...3.28 FATAL_ERROR)
cmake_policy(VERSION 3.19...3.28)

find_package(LibLZMA)
if(LibLZMA_FOUND)
  message(STATUS "LZMA installation found. Boost iostream will be build with lzma compression")
else()
  message(WARNING "LZMA installation not found. Boost iostream will be build without lzma compression")
endif()

find_package(ZSTD)
if(ZSTD_FOUND)
  message(STATUS "ZSTD installation found. Boost iostream will be build with zstd compression")
else()
  message(WARNING "ZSTD installation not found. Boost iostream will be build without zstd compression")
endif()

if(APPLE AND LibLZMA_FOUND)
  set(LZMA_EXTERNAL "using lzma   :" CACHE STRING "LZMA exetrnal usage for Boost" FORCE)
  set(LZMA_VERSION "${LIBLZMA_VERSION}" CACHE STRING "LZMA version info for Boost" FORCE)
  set(LZMA_STRING ": <include>${LIBLZMA_INCLUDE_DIR}  <search>${LIBLZMA_LIBRARY} ;" CACHE STRING "LZMA install info for Boost" FORCE)
else()
  set(LZMA_EXTERNAL "" CACHE STRING "LZMA exetrnal usage for Boost" FORCE)
  set(LZMA_VERSION "" CACHE STRING "LZMA version info for Boost" FORCE)
  set(LZMA_STRING "" CACHE STRING "LZMA install info for Boost" FORCE)
endif()

if(APPLE AND ZSTD_FOUND)
  get_filename_component(ZSTD_LIBRARY_DIR ${ZSTD_LIBRARY} DIRECTORY)
  set(ZSTD_EXTERNAL "using zstd   :" CACHE STRING "ZSTD exetrnal usage for Boost" FORCE)
  set(ZSTD_VERSION "${ZSTD_VERSION}" CACHE STRING "ZSTD version info for Boost" FORCE)
  set(ZSTD_STRING ": <include>${ZSTD_INCLUDE_DIR} <search>${ZSTD_LIBRARY_DIR} ;" CACHE STRING "ZSTD install info for Boost" FORCE)
else()
  set(ZSTD_EXTERNAL "" CACHE STRING "ZSTD exetrnal usage for Boost" FORCE)
  set(ZSTD_VERSION "" CACHE STRING "ZSTD version info for Boost" FORCE)
  set(ZSTD_STRING "" CACHE STRING "ZSTD install info for Boost" FORCE)
endif()


find_package(Git REQUIRED)
find_package(Patch REQUIRED)
find_package(UnixCommands)
set(patch $<TARGET_FILE:Patch::patch> --merge)

set(PROJECT_MIN_CXX_STANDARD 17)

include(FairSoftLib)
set_fairsoft_defaults()
message(STATUS "NCPUS: ${NCPUS} (from ${NCPUS_SOURCE})")

if(NOT DEFINED GEANT4MT)
  set(GEANT4MT OFF)
endif()

include(ExternalProject)

set_property(DIRECTORY PROPERTY EP_BASE ${CMAKE_BINARY_DIR})
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
if (CMAKE_TOOLCHAIN_FILE)
  list(APPEND CMAKE_DEFAULT_ARGS -DCMAKE_TOOLCHAIN_FILE:STRING=${CMAKE_TOOLCHAIN_FILE})
endif()
if(APPLE)
  set(CMAKE_DEFAULT_ARGS ${CMAKE_DEFAULT_ARGS}
    "-DCMAKE_MACOSX_RPATH:BOOL=ON"
  )
  if(CMAKE_OSX_SYSROOT)
    set(CMAKE_DEFAULT_ARGS ${CMAKE_DEFAULT_ARGS}
      "-DCMAKE_OSX_SYSROOT:PATH=${CMAKE_OSX_SYSROOT}"
    )
  endif()
endif()
if(ICU_ROOT)
  set(icu "-DICU_ROOT=${ICU_ROOT}")
  set(boost_icu_config "--with-icu=${ICU_ROOT}")
endif()
find_package(Python 3 REQUIRED COMPONENTS Interpreter Development)
get_target_property(Python_EXECUTABLE Python::Interpreter LOCATION)
get_filename_component(Python_EXECUTABLE_NAME "${Python_EXECUTABLE}" NAME)
configure_file(${CMAKE_SOURCE_DIR}/legacy/boost/site-config.jam.in ${CMAKE_BINARY_DIR}/site-config.jam @ONLY)
set(boost_python_config_bootstrap "--with-python=${Python_EXECUTABLE}")
set(boost_python_config_b2 "--site-config=${CMAKE_BINARY_DIR}/site-config.jam")
set(cmake_python_config_old "-DPYTHON_EXECUTABLE=${Python_EXECUTABLE}"
  "-DPYTHON_INCLUDE_DIR=${Python_INCLUDE_DIRS}" "-DPYTHON_LIBRARY=${Python_LIBRARIES}")
set(cmake_python_config "-DPython_EXECUTABLE=${Python_EXECUTABLE}")
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

if(SOURCE_CACHE)
  set_property(DIRECTORY PROPERTY EP_UPDATE_DISCONNECTED ON)
  add_custom_target(extract-source-cache
    DEPENDS "${CMAKE_BINARY_DIR}/extracted"
  )
  add_custom_command(OUTPUT "${CMAKE_BINARY_DIR}/extracted"
    COMMAND ${TAR} xzf ${SOURCE_CACHE}
    COMMAND ${CMAKE_COMMAND} -E touch "${CMAKE_BINARY_DIR}/extracted"
    VERBATIM COMMAND_EXPAND_LISTS
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Extracting source cache ${SOURCE_CACHE} at ${CMAKE_BINARY_DIR}"
  )
  set_property(DIRECTORY PROPERTY EP_STEP_TARGETS mkdir download update patch configure build install test)
  set(DEPENDS_ON_SOURCE_CACHE DEPENDS extract-source-cache)
  set(extract_source_cache_target extract-source-cache)
else()
  unset(DEPENDS_ON_SOURCE_CACHE)
  unset(extract_source_cache_target)
endif()

unset(packages)

list(APPEND packages faircmakemodules)
set(faircmakemodules_version "1.0.0")
ExternalProject_Add(faircmakemodules
  GIT_REPOSITORY https://github.com/FairRootGroup/FairCMakeModules GIT_TAG v${faircmakemodules_version}
  ${CMAKE_DEFAULT_ARGS}
  ${LOG_TO_FILE}
  ${DEPENDS_ON_SOURCE_CACHE}
)

list(APPEND packages boost)
set(boost_version "83")
set(boost_features
  "cxxstd=${CMAKE_CXX_STANDARD}"
  "link=shared"
  "threading=multi"
  "variant=release"
  "visibility=hidden"
  "pch=off"
)

list(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)

if("${isSystemDir}" STREQUAL "-1")
  list(APPEND boost_features
    "hardcode-dll-paths=true"
    "dll-path=${CMAKE_INSTALL_PREFIX}/lib"
  )
endif()

ExternalProject_Add(boost
  URL "https://boostorg.jfrog.io/artifactory/main/release/1.${boost_version}.0/source/boost_1_${boost_version}_0.tar.bz2"
  URL_HASH SHA256=6478edfe2f3305127cffe8caf73ea0176c53769f4bf1585be237eb30798c3b8e
  BUILD_IN_SOURCE ON
  CONFIGURE_COMMAND "./bootstrap.sh"
    "--prefix=${CMAKE_INSTALL_PREFIX}"
    ${boost_python_config_bootstrap}
    ${boost_icu_config}
  BUILD_COMMAND "./b2" "--layout=system"
    ${boost_features}
    ${boost_python_config_b2}
    "-j ${NCPUS}"
  INSTALL_COMMAND "./b2"
    ${boost_features}
    ${boost_python_config_b2}
    "-j ${NCPUS}"
    "install"
  ${LOG_TO_FILE}
  ${DEPENDS_ON_SOURCE_CACHE}
)

list(APPEND packages fmt)
set(fmt_version "10.1.1")
ExternalProject_Add(fmt
  URL "https://github.com/fmtlib/fmt/releases/download/${fmt_version}/fmt-${fmt_version}.zip"
  URL_HASH SHA256=b84e58a310c9b50196cda48d5678d5fa0849bca19e5fdba6b684f0ee93ed9d1b
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DFMT_DOC=OFF"
  ${LOG_TO_FILE}
  ${DEPENDS_ON_SOURCE_CACHE}
)

if(ICU_ROOT)
  set(dds_icu_hint "-DDDS_LD_LIBRARY_PATH=${ICU_ROOT}/lib")
endif()
list(APPEND packages dds)
set(dds_version "3.8")
ExternalProject_Add(dds
  GIT_REPOSITORY https://github.com/FairRootGroup/DDS GIT_TAG ${dds_version}
  PATCH_COMMAND ${patch} -p1 -i "${CMAKE_SOURCE_DIR}/legacy/dds/relax_protobuf_requirement.patch"
  UPDATE_DISCONNECTED ON
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    ${dds_icu_hint}
  DEPENDS boost ${extract_source_cache_target}
  ${LOG_TO_FILE}
  EXCLUDE_FROM_ALL ON
)
ExternalProject_Add_Step(dds build_wn_bin DEPENDEES build DEPENDERS install
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/Build/dds
  COMMAND ${CMAKE_COMMAND} --build . --target wn_bin -j "${NCPUS}"
  LOG ON
)

list(APPEND packages fairlogger)
set(fairlogger_version "1.11.1")
ExternalProject_Add(fairlogger
  GIT_REPOSITORY https://github.com/FairRootGroup/FairLogger GIT_TAG v${fairlogger_version}
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DUSE_EXTERNAL_FMT=ON"
  DEPENDS boost fmt ${extract_source_cache_target}
  ${LOG_TO_FILE}
)

list(APPEND packages zeromq)
set(zeromq_version "4.3.5")
ExternalProject_Add(zeromq
  GIT_REPOSITORY https://github.com/zeromq/libzmq GIT_TAG v${zeromq_version}
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DWITH_PERF_TOOL=ON"
    "-DZMQ_BUILD_TESTS=ON"
    "-DENABLE_CPACK=OFF"
    "-DENABLE_DRAFTS=ON"
  ${LOG_TO_FILE}
  ${DEPENDS_ON_SOURCE_CACHE}
)

list(APPEND packages flatbuffers)
set(flatbuffers_version "23.5.26")
ExternalProject_Add(flatbuffers
  GIT_REPOSITORY https://github.com/google/flatbuffers GIT_TAG v${flatbuffers_version}
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DFLATBUFFERS_BUILD_SHAREDLIB=ON"
    "-DFLATBUFFERS_BUILD_FLATLIB=OFF"
    "-DFLATBUFFERS_BUILD_TESTS=OFF"
  ${LOG_TO_FILE}
  ${DEPENDS_ON_SOURCE_CACHE}
)

list(APPEND packages fairmq)
set(fairmq_version "1.8.4")
ExternalProject_Add(fairmq
  GIT_REPOSITORY https://github.com/FairRootGroup/FairMQ GIT_TAG v${fairmq_version}
  ${CMAKE_DEFAULT_ARGS}
  DEPENDS boost fairlogger zeromq ${extract_source_cache_target}
  ${LOG_TO_FILE}
)

list(APPEND packages pythia6)
set(pythia6_version "428-alice1")
ExternalProject_Add(pythia6
  URL https://github.com/alisw/pythia6/archive/${pythia6_version}.tar.gz
  URL_HASH SHA256=b14e82870d3aa33d6fa07f4b1f4d17f1ab80a37d753f91ca6322352b397cb244
  UPDATE_DISCONNECTED ON
  PATCH_COMMAND ${patch} -p1 -i "${CMAKE_SOURCE_DIR}/legacy/pythia6/add_missing_extern_keyword.patch"
  ${CMAKE_DEFAULT_ARGS} ${LOG_TO_FILE}
  ${DEPENDS_ON_SOURCE_CACHE}
)

list(APPEND packages hepmc)
set(hepmc_version "2.06.11")
ExternalProject_Add(hepmc
  URL https://hepmc.web.cern.ch/releases/hepmc${hepmc_version}.tgz
  URL_HASH SHA256=86b66ea0278f803cde5774de8bd187dd42c870367f1cbf6cdaec8dc7cf6afc10
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-Dlength:STRING=CM"
    "-Dmomentum:STRING=GEV"
  ${LOG_TO_FILE}
  ${DEPENDS_ON_SOURCE_CACHE}
)

list(APPEND packages vc)
set(vc_version "1.4.4")
ExternalProject_Add(vc
  URL https://github.com/VcDevel/Vc/archive/refs/tags/${vc_version}.tar.gz
  URL_HASH SHA256=5933108196be44c41613884cd56305df320263981fe6a49e648aebb3354d57f3
  ${CMAKE_DEFAULT_ARGS} ${LOG_TO_FILE}
  ${DEPENDS_ON_SOURCE_CACHE}
)

list(APPEND packages clhep)
set(clhep_version "2.4.7.1")
ExternalProject_Add(clhep
  URL https://proj-clhep.web.cern.ch/proj-clhep/dist1/clhep-${clhep_version}.tgz
  URL_HASH SHA256=1c8304a7772ac6b99195f1300378c6e3ddf4ad07c85d64a04505652abb8a55f9
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DCLHEP_BUILD_CXXSTD=-std=c++${CMAKE_CXX_STANDARD}"
  ${LOG_TO_FILE}
  ${DEPENDS_ON_SOURCE_CACHE}
)
set(clhep_source ${CMAKE_BINARY_DIR}/Source/clhep)
ExternalProject_Add_Step(clhep move_dir DEPENDEES download DEPENDERS patch
  COMMAND ${CMAKE_COMMAND} -E copy_directory "${clhep_source}/CLHEP" "${clhep_source}"
  BYPRODUCTS "${clhep_source}/CMakeLists.txt"
  INDEPENDENT ON
  LOG ON
)

list(APPEND packages pythia8)
set(pythia8_version "8310")
string(SUBSTRING "${pythia8_version}" 0 2 pythia8_major_version)
string(TOUPPER "${CMAKE_BUILD_TYPE}" selected)
ExternalProject_Add(pythia8
  URL https://pythia.org/download/pythia${pythia8_major_version}/pythia${pythia8_version}.tgz
  URL_HASH SHA256=90c811abe7a3d2ffdbf9b4aeab51cf6e0a5a8befb4e3efa806f3d5b9c311e227
  BUILD_IN_SOURCE ON
  CONFIGURE_COMMAND ${CMAKE_BINARY_DIR}/Source/pythia8/configure
    "--with-hepmc2=${CMAKE_INSTALL_PREFIX}"
    "--prefix=${CMAKE_INSTALL_PREFIX}"
    "--cxx=${CMAKE_CXX_COMPILER}"
    "--cxx-common='${CMAKE_CXX_FLAGS_${selected}} -fPIC -std=c++${CMAKE_CXX_STANDARD}'"
  DEPENDS hepmc ${extract_source_cache_target}
  ${LOG_TO_FILE}
)

list(APPEND packages geant4)
set(geant4_version "11.2.0")
if(GEANT4MT)
  set(mt
    "-DGEANT4_BUILD_MULTITHREADED=ON"
    "-DGEANT4_BUILD_TLS_MODEL=global-dynamic")
else()
  set(mt
    "-DGEANT4_BUILD_MULTITHREADED=OFF")
endif()
ExternalProject_Add(geant4
  URL https://geant4-data.web.cern.ch/releases/geant4-v${geant4_version}.tar.gz
  URL_HASH SHA256=46ad7fab3c5cb4bd0bdd77dd6d3e2283184819235bcbc01b2d117d81b35596a6
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}"
    ${mt}
    "-DGEANT4_USE_SYSTEM_CLHEP=ON"
    "-DGEANT4_USE_SYSTEM_EXPAT=ON"
    "-DGEANT4_USE_SYSTEM_ZLIB=ON"
    "-DGEANT4_USE_G3TOG4=ON"
    "-DGEANT4_USE_GDML=ON"
    "-DGEANT4_USE_OPENGL_X11=OFF"
    "-DGEANT4_USE_RAYTRACER_X11=OFF"
    "-DGEANT4_USE_PYTHON=ON"
    "-DGEANT4_INSTALL_DATA=ON"
    "-DGEANT4_INSTALL_DATA_TIMEOUT=36000"
    "-DGEANT4_BUILD_STORE_TRAJECTORY=OFF"
    "-DGEANT4_BUILD_VERBOSE_CODE=ON"
    "-DGEANT4_BUILD_BUILTIN_BACKTRACE=OFF"
    ${cmake_python_config_old}
  DEPENDS boost clhep ${extract_source_cache_target}
  ${LOG_TO_FILE}
)

list(APPEND packages root)
set(root_version "6.30.04")
string(REPLACE "\." "-" root_version_gittag ${root_version})
if(APPLE AND CMAKE_VERSION VERSION_GREATER 3.15)
  set(root_builtin_glew "-Dbuiltin_glew=ON")
endif()
if(APPLE)
  set(root_cocoa "-Dcocoa=ON")
  set(root_x11 OFF)
else()
  unset(root_cocoa)
  set(root_x11 ON)
endif()
ExternalProject_Add(root
  GIT_REPOSITORY https://github.com/root-project/root/ GIT_TAG v${root_version_gittag}
  GIT_SHALLOW 1
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-Daqua=ON"
    "-Dasimage=ON"
    "-Dbuiltin_nlohmannjson=ON"
    "-Dcintex=OFF"
    "-Ddavix=OFF"
    "-Dfftw3=ON"
    "-Dfortran=ON"
    "-Dgdml=ON"
    "-Dglobus=OFF"
    "-Dgnuinstall=ON"
    "-Dhttp=ON"
    "-Dmathmore=ON"
    "-Dminuit2=ON"
    "-Dmlp=ON"
    "-Dpyroot=ON"
    "-Dpythia6=ON"
    "-Dreflex=OFF"
    "-Droofit=ON"
    "-Druntime_cxxmodules=OFF"
    "-Drpath=ON"
    "-Dsoversion=ON"
    "-Dspectrum=ON"
    "-Dsqlite=ON"
    "-Dtmva=ON"
    "-Dvc=ON"
    "-Dvdt=OFF"
    "-Dxml=ON"
    "-Dxrootd=ON"
    "-Dx11=${root_x11}"
    ${cmake_python_config}
    ${cmake_python_config_old}
    ${root_builtin_glew}
    ${root_cocoa}
  UPDATE_DISCONNECTED ON
  PATCH_COMMAND ${patch} -p1 -i "${CMAKE_SOURCE_DIR}/legacy/root/fix_macos_sdk_mismatch.patch"
  DEPENDS pythia6 pythia8 vc ${extract_source_cache_target}
  ${LOG_TO_FILE}
)

list(APPEND packages vmc)
set(vmc_version "2-0")
ExternalProject_Add(vmc
  GIT_REPOSITORY https://github.com/vmc-project/vmc GIT_TAG v${vmc_version}
  ${CMAKE_DEFAULT_ARGS} ${LOG_TO_FILE}
  DEPENDS root ${extract_source_cache_target}
)

list(APPEND packages geant3)
set(geant3_version "4-2_fairsoft")
ExternalProject_Add(geant3
  GIT_REPOSITORY https://github.com/FairRootGroup/geant3 GIT_TAG v${geant3_version}
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DBUILD_GCALOR=ON"
  DEPENDS root vmc ${extract_source_cache_target}
  ${LOG_TO_FILE}
)

list(APPEND packages vgm)
set(vgm_version "5-2")
ExternalProject_Add(vgm
  GIT_REPOSITORY https://github.com/vmc-project/vgm GIT_TAG v${vgm_version}
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DWITH_TEST=OFF"
  DEPENDS clhep geant4 root ${extract_source_cache_target}
  ${LOG_TO_FILE}
)

list(APPEND packages geant4_vmc)
set(geant4_vmc_version "6-5")
ExternalProject_Add(geant4_vmc
  GIT_REPOSITORY https://github.com/vmc-project/geant4_vmc GIT_TAG v${geant4_vmc_version}
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DGeant4VMC_USE_VGM=ON"
    "-DGeant4VMC_USE_GEANT4_UI=OFF"
    "-DGeant4VMC_USE_GEANT4_VIS=OFF"
    "-DGeant4VMC_USE_GEANT4_G3TOG4=ON"
    "-DWITH_TEST=OFF"
  DEPENDS clhep geant4 root vgm vmc ${extract_source_cache_target}
  ${LOG_TO_FILE}
)

list(APPEND packages onnxruntime)
set(onnxruntime_version "1.12.1")
ExternalProject_Add(onnxruntime
  UPDATE_DISCONNECTED ON
  PATCH_COMMAND ${patch} -p1 -i "${CMAKE_SOURCE_DIR}/legacy/onnxruntime/install_config_files.patch"
  COMMAND ${patch} -p1 -i "${CMAKE_SOURCE_DIR}/legacy/onnxruntime/fix_python_detection.patch"
  GIT_REPOSITORY https://github.com/microsoft/onnxruntime/ GIT_TAG v${onnxruntime_version}
  GIT_SHALLOW ON
  GIT_SUBMODULES
    "cmake/external/SafeInt"
    "cmake/external/date"
    "cmake/external/flatbuffers" # at the moment, there is no option to consume external
    "cmake/external/json"
    "cmake/external/mp11"
    "cmake/external/nsync"
    "cmake/external/onnx"
    "cmake/external/protobuf" # TODO explore, if we can offer this as separate pkg (conditionally?)
    "cmake/external/pytorch_cpuinfo"
    "cmake/external/re2"
    "cmake/external/eigen"
  SOURCE_SUBDIR cmake
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-Donnxruntime_BUILD_UNIT_TESTS=OFF"
    "-Donnxruntime_BUILD_SHARED_LIB=ON"
  DEPENDS ${extract_source_cache_target}
  EXCLUDE_FROM_ALL ON
  ${LOG_TO_FILE}
)

ExternalProject_Add(fairsoft-config
  GIT_REPOSITORY https://github.com/FairRootGroup/fairsoft-config GIT_TAG master
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
  "-DFAIRSOFT_VERSION=jan24"
  DEPENDS root ${extract_source_cache_target}
  ${LOG_TO_FILE}
)

if(TARGET geant4-download)
  add_custom_target(geant4-download-data
    ${CMAKE_COMMAND} -S "${CMAKE_BINARY_DIR}/Source/geant4" -B . -DGEANT4_INSTALL_DATA=ON
    COMMAND ${CMAKE_COMMAND} --build . --target G4ABLA
    COMMAND ${CMAKE_COMMAND} --build . --target G4NDL
    COMMAND ${CMAKE_COMMAND} --build . --target G4EMLOW
    COMMAND ${CMAKE_COMMAND} --build . --target G4ENSDFSTATE
    COMMAND ${CMAKE_COMMAND} --build . --target G4INCL
    COMMAND ${CMAKE_COMMAND} --build . --target G4NDL
    COMMAND ${CMAKE_COMMAND} --build . --target G4PARTICLEXS
    COMMAND ${CMAKE_COMMAND} --build . --target G4PII
    COMMAND ${CMAKE_COMMAND} --build . --target G4SAIDDATA
    COMMAND ${CMAKE_COMMAND} --build . --target PhotonEvaporation
    COMMAND ${CMAKE_COMMAND} --build . --target RadioactiveDecay
    COMMAND ${CMAKE_COMMAND} --build . --target RealSurface
    COMMAND ${BASH} -c "rm -rf Externals/**/src/*-{build,stamp}"
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/Build/geant4"
    DEPENDS geant4-download VERBATIM
  )
  set(g4data geant4-download-data)
else()
  unset(g4data)
endif()
unset(deps)
unset(tardirs)
foreach(pkg IN LISTS packages)
  list(APPEND deps "${pkg}-download")
  list(APPEND tardirs "Download/${pkg}" "Source/${pkg}")
endforeach()
list(APPEND tardirs "Stamp/*/*-git*.txt")
if(TARGET geant4-download-data)
  list(APPEND tardirs "Build/geant4/Externals")
endif()
execute_process(COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE SHORT_HASH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
set(tarfile ${CMAKE_BINARY_DIR}/FairSoft_source_cache_${SHORT_HASH}.tar.gz)
list(JOIN tardirs " " tarargs)
add_custom_target(source-cache
  ${BASH} -c "tar czf ${tarfile} ${tarargs}"
  DEPENDS ${g4data} ${deps} VERBATIM COMMAND_EXPAND_LISTS
  COMMENT "Creating source cache at ${tarfile}"
)

include(CTest)

foreach(ver IN ITEMS 18.6 18.8 19.0)
  set(TEST_VERSION v${ver}_patches)
  configure_file(test/legacy/fairroot.sh.in ${CMAKE_BINARY_DIR}/test_fairroot_${ver}.sh @ONLY)
  add_test(NAME FairRoot_${ver}
           COMMAND test_fairroot_${ver}.sh
           WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
endforeach()

### Summary
message(STATUS "  ")
message(STATUS "  ${Cyan}CXX STANDARD${CR}       ${BGreen}C++${CMAKE_CXX_STANDARD}${CR} (change with ${BMagenta}-DCMAKE_CXX_STANDARD=17${CR})")
message(STATUS "  ")
message(STATUS "  ${Cyan}BUILD TYPE${CR}         ${BGreen}${CMAKE_BUILD_TYPE}${CR} (change with ${BMagenta}-DCMAKE_BUILD_TYPE=...${CR})")
if(packages)
  list(SORT packages)
  message(STATUS "  ")
  message(STATUS "  ${Cyan}PACKAGE              VERSION         OPTION${CR}")
  foreach(dep IN LISTS packages)
    if(dep STREQUAL boost)
      set(version_str "1.${${dep}_version}.0")
    elseif(dep STREQUAL geant4)
      set(version_str "${${dep}_version}")
      if(GEANT4MT)
        set(comment "multi-threaded (change with ${BMagenta}-DGEANT4MT=OFF${CR})")
      else()
        set(comment "single-threaded (change with ${BMagenta}-DGEANT4MT=ON${CR})")
      endif()
    elseif(dep STREQUAL dds OR dep STREQUAL onnxruntime)
      set(version_str "${${dep}_version}")
      set(comment "optional (by building target ${BMagenta}${dep}${CR} explicitely)")
    else()
      set(version_str "${${dep}_version}")
    endif()
    if(DISABLE_COLOR)
      pad("${BYellow}${version_str}${CR}" 15 " " version_padded)
    else()
      pad("${BYellow}${version_str}${CR}" 15 " " version_padded COLOR 1)
    endif()
    pad(${dep} 20 " " dep_padded)
    message(STATUS "  ${BWhite}${dep_padded}${CR}${version_padded}${comment}")
    unset(version_str)
    unset(version_padded)
    unset(comment)
  endforeach()
endif()
message(STATUS "  ")
if(SOURCE_CACHE)
  message(STATUS "  ${Cyan}SOURCE CACHE${CR}       ${BGreen}${SOURCE_CACHE}${CR}")
else()
  message(STATUS "  ${Cyan}SOURCE CACHE${CR}       using upstream URLs (generate cache by building target 'source-cache' and pass via ${BMagenta}-DSOURCE_CACHE=...${CR})")
endif()
if(CMAKE_OSX_SYSROOT)
  message(STATUS "  ")
  message(STATUS "  ${Cyan}OSX_SYSROOT${CR}        ${BGreen}${CMAKE_OSX_SYSROOT}${CR} (change with ${BMagenta}-DCMAKE_OSX_SYSROOT=...${CR})")
endif()
message(STATUS "  ")
message(STATUS "  ${Cyan}INSTALL PREFIX${CR}     ${BGreen}${CMAKE_INSTALL_PREFIX}${CR} (change with ${BMagenta}-DCMAKE_INSTALL_PREFIX=...${CR})")
message(STATUS "  ")
message(STATUS "  ${Cyan} -> export SIMPATH=${CMAKE_INSTALL_PREFIX}${CR}")
message(STATUS "  ")
