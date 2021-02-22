################################################################################
# Copyright (C) 2020-2021 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH  #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################
cmake_minimum_required(VERSION 3.16.1 FATAL_ERROR)
cmake_policy(VERSION 3.16.1...3.19)
if(POLICY CMP0114)
  cmake_policy(SET CMP0114 OLD)
endif()

find_package(Git REQUIRED)
find_package(Patch REQUIRED)
find_package(UnixCommands)
set(patch $<TARGET_FILE:Patch::patch> --merge)

set(PROJECT_MIN_CXX_STANDARD 17)

include(FairSoftLib)
set_fairsoft_defaults()

if(NOT PACKAGE_SET)
  set(PACKAGE_SET full)
endif()
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
if(APPLE)
  set(CMAKE_DEFAULT_ARGS ${CMAKE_DEFAULT_ARGS}
    "-DCMAKE_MACOSX_RPATH:BOOL=ON"
  )
endif()
unset(python)
if(ICU_ROOT)
  set(icu "-DICU_ROOT=${ICU_ROOT}")
  set(boost_icu_config "--with-icu=${ICU_ROOT}")
endif()
if(PYTHON_EXECUTABLE)
  set(python "-DPYTHON_EXECUTABLE=${PYTHON_EXECUTABLE}")
  get_filename_component(PYTHON_EXECUTABLE_FILE "${PYTHON_EXECUTABLE}" NAME)
  set(boost_python_config "--with-python=${PYTHON_EXECUTABLE_FILE}")
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

if(SOURCE_CACHE)
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
  set_property(DIRECTORY PROPERTY EP_UPDATE_DISCONNECTED ON)
  set_property(DIRECTORY PROPERTY EP_STEP_TARGETS mkdir download update patch configure build install test)
  set(DEPENDS_ON_SOURCE_CACHE DEPENDS extract-source-cache)
  set(extract_source_cache_target extract-source-cache)
else()
  set_property(DIRECTORY PROPERTY EP_STEP_TARGETS configure build install test)
  set_property(DIRECTORY PROPERTY EP_INDEPENDENT_STEP_TARGETS mkdir download update patch)
  unset(DEPENDS_ON_SOURCE_CACHE)
  unset(extract_source_cache_target)
endif()

unset(packages)

list(APPEND packages boost)
set(boost_version "72")
ExternalProject_Add(boost
  URL "https://dl.bintray.com/boostorg/release/1.${boost_version}.0/source/boost_1_${boost_version}_0.tar.bz2"
  URL_HASH SHA256=59c9b274bc451cf91a9ba1dd2c7fdcaf5d60b1b3aa83f2c9fa143417cc660722
  BUILD_IN_SOURCE ON
  CONFIGURE_COMMAND "./bootstrap.sh"
    "--prefix=${CMAKE_INSTALL_PREFIX}"
    ${boost_python_config} ${boost_icu_config}
  PATCH_COMMAND ${patch} -p2 -i "${CMAKE_SOURCE_DIR}/legacy/boost/1.72_boost_process.patch"
  BUILD_COMMAND "./b2" "--layout=system"
    "cxxstd=${CMAKE_CXX_STANDARD}"
    "link=shared"
    "threading=multi"
    "variant=release"
    "visibility=hidden"
  INSTALL_COMMAND "./b2" "install" "-j" "${NCPUS}"
  ${LOG_TO_FILE}
  ${DEPENDS_ON_SOURCE_CACHE}
)

list(APPEND packages fmt)
set(fmt_version "6.1.2")
ExternalProject_Add(fmt
  URL "https://github.com/fmtlib/fmt/releases/download/${fmt_version}/fmt-${fmt_version}.zip"
  URL_HASH SHA256=63650f3c39a96371f5810c4e41d6f9b0bb10305064e6faf201cbafe297ea30e8
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DFMT_DOC=OFF"
  ${LOG_TO_FILE}
  ${DEPENDS_ON_SOURCE_CACHE}
)

list(APPEND packages dds)
set(dds_version "3.5.9")
ExternalProject_Add(dds
  GIT_REPOSITORY https://github.com/FairRootGroup/DDS GIT_TAG ${dds_version}
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DBoost_NO_BOOST_CMAKE=ON"
  PATCH_COMMAND ${patch} -p1 -i "${CMAKE_SOURCE_DIR}/legacy/dds/fix_boost_lookup.patch"
  DEPENDS boost ${extract_source_cache_target}
  ${LOG_TO_FILE}
)
ExternalProject_Add_Step(dds build_wn_bin DEPENDEES build DEPENDERS install
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/Build/dds
  COMMAND ${CMAKE_COMMAND} --build . --target wn_bin -j "${NCPUS}"
  LOG ON
)

list(APPEND packages fairlogger)
set(fairlogger_version "1.9.0")
ExternalProject_Add(fairlogger
  GIT_REPOSITORY https://github.com/FairRootGroup/FairLogger GIT_TAG v${fairlogger_version}
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DUSE_EXTERNAL_FMT=ON"
  DEPENDS boost fmt ${extract_source_cache_target}
  ${LOG_TO_FILE}
)

list(APPEND packages zeromq)
set(zeromq_version "4.3.2")
ExternalProject_Add(zeromq
  GIT_REPOSITORY https://github.com/zeromq/libzmq GIT_TAG v${zeromq_version}
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DWITH_PERF_TOOL=ON"
    "-DZMQ_BUILD_TESTS=ON"
    "-DENABLE_CPACK=OFF"
  ${LOG_TO_FILE}
  ${DEPENDS_ON_SOURCE_CACHE}
)

list(APPEND packages flatbuffers)
set(flatbuffers_version "1.12.0")
ExternalProject_Add(flatbuffers
  GIT_REPOSITORY https://github.com/google/flatbuffers GIT_TAG v${flatbuffers_version}
  ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DFLATBUFFERS_BUILD_SHAREDLIB=ON"
    "-DFLATBUFFERS_BUILD_FLATLIB=OFF"
  PATCH_COMMAND ${patch} -p1 -i "${CMAKE_SOURCE_DIR}/legacy/flatbuffers/remove_werror.patch"
  ${LOG_TO_FILE}
  ${DEPENDS_ON_SOURCE_CACHE}
)

if (NOT PACKAGE_SET STREQUAL fairmqdev)
  list(APPEND packages fairmq)
  set(fairmq_version "1.4.31")
  ExternalProject_Add(fairmq
    GIT_REPOSITORY https://github.com/FairRootGroup/FairMQ GIT_TAG v${fairmq_version}
    ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
      "-DBUILD_DDS_PLUGIN=ON"
      "-DBUILD_SDK_COMMANDS=ON"
      "-DBUILD_SDK=ON"
    DEPENDS boost dds fairlogger flatbuffers zeromq ${extract_source_cache_target}
    ${LOG_TO_FILE}
  )

  list(APPEND packages odc)
  set(odc_version "0.16")
  ExternalProject_Add(odc
    GIT_REPOSITORY https://github.com/FairRootGroup/ODC GIT_TAG ${odc_version}
    ${CMAKE_DEFAULT_ARGS}
    DEPENDS boost dds fairlogger fairmq ${extract_source_cache_target}
    ${LOG_TO_FILE}
  )
endif()

if(PACKAGE_SET STREQUAL full)
  list(APPEND packages pythia6)
  set(pythia6_version "428-alice1")
  ExternalProject_Add(pythia6
    URL https://github.com/alisw/pythia6/archive/${pythia6_version}.tar.gz
    URL_HASH SHA256=b14e82870d3aa33d6fa07f4b1f4d17f1ab80a37d753f91ca6322352b397cb244
    PATCH_COMMAND ${patch} -p1 -i "${CMAKE_SOURCE_DIR}/legacy/pythia6/add_missing_extern_keyword.patch"
    ${CMAKE_DEFAULT_ARGS} ${LOG_TO_FILE}
    ${DEPENDS_ON_SOURCE_CACHE}
  )

  list(APPEND packages hepmc)
  set(hepmc_version "2.06.11")
  ExternalProject_Add(hepmc
    URL https://hepmc.web.cern.ch/hepmc/releases/hepmc${hepmc_version}.tgz
    URL_HASH SHA256=86b66ea0278f803cde5774de8bd187dd42c870367f1cbf6cdaec8dc7cf6afc10
    ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
      "-Dlength:STRING=CM"
      "-Dmomentum:STRING=GEV"
    ${LOG_TO_FILE}
    ${DEPENDS_ON_SOURCE_CACHE}
  )

  list(APPEND packages vc)
  set(vc_version "1.4.1")
  ExternalProject_Add(vc
    URL https://github.com/VcDevel/Vc/archive/${vc_version}.tar.gz
    URL_HASH SHA256=7e8b57ed5ff9eb0835636203898c21302733973ff8eaede5134dd7cb87f915f6
    ${CMAKE_DEFAULT_ARGS} ${LOG_TO_FILE}
    ${DEPENDS_ON_SOURCE_CACHE}
  )

  list(APPEND packages clhep)
  set(clhep_version "2.4.4.0")
  ExternalProject_Add(clhep
    URL http://proj-clhep.web.cern.ch/proj-clhep/dist1/clhep-${clhep_version}.tgz
    URL_HASH SHA256=5df78c11733a091da9ae5a24ce31161d44034dd45f20455587db85f1ca1ba539
    ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
      "-DCLHEP_BUILD_CXXSTD=-std=c++${CMAKE_CXX_STANDARD}"
    ${LOG_TO_FILE}
    ${DEPENDS_ON_SOURCE_CACHE}
  )
  set(clhep_source ${CMAKE_BINARY_DIR}/Source/clhep)
  ExternalProject_Add_Step(clhep move_dir DEPENDEES download DEPENDERS patch
    COMMAND ${CMAKE_COMMAND} -E copy_directory "${clhep_source}/CLHEP" "${clhep_source}"
    BYPRODUCTS "${clhep_source}/CMakeLists.txt"
    LOG ON
  )

  list(APPEND packages pythia8)
  set(pythia8_version "8303")
  string(TOUPPER "${CMAKE_BUILD_TYPE}" selected)
  ExternalProject_Add(pythia8
    URL http://home.thep.lu.se/~torbjorn/pythia8/pythia${pythia8_version}.tgz
    URL_HASH SHA256=cd7c2b102670dae74aa37053657b4f068396988ef7da58fd3c318c84dc37913e
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
  set(geant4_version "10.7.1")
  if(GEANT4MT)
    set(mt
      "-DGEANT4_BUILD_MULTITHREADED=ON"
      "-DGEANT4_BUILD_TLS_MODEL=global-dynamic")
  else()
    set(mt
      "-DGEANT4_BUILD_MULTITHREADED=OFF")
  endif()
  ExternalProject_Add(geant4
    URL https://gitlab.cern.ch/geant4/geant4/-/archive/v${geant4_version}/geant4-v${geant4_version}.tar.gz
    URL_HASH SHA256=2aa7cb4b231081e0a35d84c707be8f35e4edc4e97aad2b233943515476955293
    ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
      "-DGEANT4_BUILD_CXXSTD=${CMAKE_CXX_STANDARD}"
      ${mt}
      "-DGEANT4_USE_SYSTEM_CLHEP=ON"
      "-DGEANT4_USE_SYSTEM_EXPAT=ON"
      "-DGEANT4_USE_SYSTEM_ZLIB=ON"
      "-DGEANT4_USE_G3TOG4=ON"
      "-DGEANT4_USE_GDML=ON"
      "-DGEANT4_USE_OPENGL_X11=ON"
      "-DGEANT4_USE_RAYTRACER_X11=ON"
      "-DGEANT4_USE_PYTHON=ON"
      "-DGEANT4_INSTALL_DATA=ON"
      "-DGEANT4_BUILD_STORE_TRAJECTORY=OFF"
      "-DGEANT4_BUILD_VERBOSE_CODE=ON"
      ${python}
    DEPENDS boost clhep ${extract_source_cache_target}
    ${LOG_TO_FILE}
  )

  list(APPEND packages root)
  set(root_version "6.22.06")
  if(APPLE AND CMAKE_VERSION VERSION_GREATER 3.15)
    set(root_builtin_glew "-Dbuiltin_glew=ON")
  endif()
  ExternalProject_Add(root
    URL https://root.cern/download/root_v${root_version}.source.tar.gz
    URL_HASH SHA256=c4688784a7e946cd10b311040b6cf0b2f75125a7520e04d1af0b746505911b57
    ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
      "-Daqua=ON"
      "-Dasimage=ON"
      "-Dcintex=OFF"
      "-Ddavix=OFF"
      "-Dfortran=ON"
      "-Dgdml=ON"
      "-Dglobus=OFF"
      "-Dgnuinstall=ON"
      "-Dhttp=ON"
      "-Dmathmore=ON"
      "-Dminuit2=ON"
      "-Dmlp=ON"
      "-Dpyroot=ON"
      "-Dreflex=OFF"
      "-Droofit=ON"
      "-Drpath=ON"
      "-Dsoversion=ON"
      "-Dspectrum=ON"
      "-Dsqlite=ON"
      "-Dtmva=ON"
      "-Dvc=ON"
      "-Dvdt=OFF"
      "-Dvmc=OFF"
      "-Dxml=ON"
      "-Dxrootd=ON"
      ${python}
      ${root_builtin_glew}
    DEPENDS pythia6 pythia8 vc ${extract_source_cache_target}
    ${LOG_TO_FILE}
  )

  list(APPEND packages vmc)
  set(vmc_version "1-0-p3")
  ExternalProject_Add(vmc
    GIT_REPOSITORY https://github.com/vmc-project/vmc GIT_TAG v${vmc_version}
    ${CMAKE_DEFAULT_ARGS} ${LOG_TO_FILE}
    DEPENDS root ${extract_source_cache_target}
  )

  list(APPEND packages geant3)
  set(geant3_version "3-8_fairsoft")
  ExternalProject_Add(geant3
    GIT_REPOSITORY https://github.com/FairRootGroup/geant3 GIT_TAG v${geant3_version}
    ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
      "-DBUILD_GCALOR=ON"
    DEPENDS root vmc ${extract_source_cache_target}
    ${LOG_TO_FILE}
  )

  list(APPEND packages vgm)
  set(vgm_version "4-8")
  ExternalProject_Add(vgm
    GIT_REPOSITORY https://github.com/vmc-project/vgm GIT_TAG v${vgm_version}
    ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
      "-DWITH_TEST=OFF"
    DEPENDS clhep geant4 root ${extract_source_cache_target}
    ${LOG_TO_FILE}
  )

  list(APPEND packages geant4_vmc)
  set(geant4_vmc_version "5-3")
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

  ExternalProject_Add(fairsoft-config
    GIT_REPOSITORY https://github.com/FairRootGroup/fairsoft-config GIT_TAG master
    ${CMAKE_DEFAULT_ARGS} CMAKE_ARGS
    "-DFAIRSOFT_VERSION=nov20"
    DEPENDS root ${extract_source_cache_target}
    ${LOG_TO_FILE}
  )
endif()

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
set(tarfile ${CMAKE_BINARY_DIR}/FairSoft_source_cache_${PACKAGE_SET}_${SHORT_HASH}.tar.gz)
list(JOIN tardirs " " tarargs)
add_custom_target(source-cache
  ${BASH} -c "tar czf ${tarfile} ${tarargs}"
  DEPENDS ${g4data} ${deps} VERBATIM COMMAND_EXPAND_LISTS
  COMMENT "Creating source cache at ${tarfile}"
)

include(CTest)

configure_file(test/legacy/fairroot.sh ${CMAKE_BINARY_DIR}/test_fairroot.sh @ONLY)
add_test(NAME FairRoot
         COMMAND test_fairroot.sh
         WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

### Summary
message(STATUS "  ")
message(STATUS "  ${Cyan}CXX STANDARD${CR}       ${BGreen}C++${CMAKE_CXX_STANDARD}${CR} (change with ${BMagenta}-DCMAKE_CXX_STANDARD=17${CR})")
message(STATUS "  ")
message(STATUS "  ${Cyan}BUILD TYPE${CR}         ${BGreen}${CMAKE_BUILD_TYPE}${CR} (change with ${BMagenta}-DCMAKE_BUILD_TYPE=...${CR})")
message(STATUS "  ")
message(STATUS "  ${Cyan}PACKAGE SET${CR}        ${BGreen}${PACKAGE_SET}${CR} (change with ${BMagenta}-DPACKAGE_SET=...${CR})")
if(packages)
  list(SORT packages)
  message(STATUS "  ")
  message(STATUS "  ${Cyan}PACKAGE       VERSION         OPTION${CR}")
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
    else()
      set(version_str "${${dep}_version}")
    endif()
    if(DISABLE_COLOR)
      pad("${BYellow}${version_str}${CR}" 15 " " version_padded)
    else()
      pad("${BYellow}${version_str}${CR}" 15 " " version_padded COLOR 1)
    endif()
    pad(${dep} 13 " " dep_padded)
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
message(STATUS "  ")
message(STATUS "  ${Cyan}INSTALL PREFIX${CR}     ${BGreen}${CMAKE_INSTALL_PREFIX}${CR} (change with ${BMagenta}-DCMAKE_INSTALL_PREFIX=...${CR})")
message(STATUS "  ")
message(STATUS "  ${Cyan} -> export SIMPATH=${CMAKE_INSTALL_PREFIX}${CR}")
message(STATUS "  ")
