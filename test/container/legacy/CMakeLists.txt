################################################################################
# Copyright (C) 2020-2022 GSI Helmholtzzentrum fuer Schwerionenforschung GmbH  #
#                                                                              #
#              This software is distributed under the terms of the             #
#              GNU Lesser General Public Licence (LGPL) version 3,             #
#                  copied verbatim in the file "LICENSE"                       #
################################################################################

function(fs_legacy_container)
  cmake_parse_arguments(ARGS "BOOTSTRAP_CMAKE" "OS;VERSION;DOCKER_TAG;PACKAGE_SETUP_SCRIPT" "" ${ARGN})

  if(ARGS_DOCKER_TAG)
    set(DOCKER_TAG ${ARGS_DOCKER_TAG})
  else()
    set(DOCKER_TAG "${ARGS_OS}:${ARGS_VERSION}")
  endif()

  if(ARGS_PACKAGE_SETUP_SCRIPT)
    set(PACKAGE_SETUP_SCRIPT "${CMAKE_SOURCE_DIR}/legacy/${ARGS_PACKAGE_SETUP_SCRIPT}")
  else()
    set(PACKAGE_SETUP_SCRIPT "${CMAKE_SOURCE_DIR}/legacy/setup-${ARGS_OS}.sh")
  endif()

  set(container "${ARGS_OS}.${ARGS_VERSION}")
  set(def "${container}.def")
  set(log "${container}.log")
  set(target "${container}.legacy.sif")

  unset(bootstrap_cmake_script)
  if(ARGS_BOOTSTRAP_CMAKE)
    configure_file("${CMAKE_CURRENT_SOURCE_DIR}/linux-cmake.def.in" ${def} @ONLY)
    set(bootstrap_cmake_script "${CMAKE_SOURCE_DIR}/bootstrap-cmake.sh")
  else()
    configure_file("${CMAKE_CURRENT_SOURCE_DIR}/linux.def.in" ${def} @ONLY)
  endif()

  add_custom_command(OUTPUT ${target}
    COMMAND ${CMAKE_COMMAND} -E env ${BASH} -c
      "${SINGULARITY} build -f -F ${target} ${def} > ${log} 2>&1"
    VERBATIM
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Building legacy container ${target}, logging to ${CMAKE_CURRENT_BINARY_DIR}/${log}"
    DEPENDS ${PACKAGE_SETUP_SCRIPT} ${bootstrap_cmake_script}
  )

  list(APPEND legacy_containers ${target})
  set(legacy_containers ${legacy_containers} PARENT_SCOPE)
endfunction()


fs_legacy_container(OS centos VERSION 7 BOOTSTRAP_CMAKE PACKAGE_SETUP_SCRIPT "setup-centos-7.sh")
fs_legacy_container(OS rockylinux VERSION 8)
fs_legacy_container(OS almalinux VERSION 9 BOOTSTRAP_CMAKE)
fs_legacy_container(OS debian VERSION 10 BOOTSTRAP_CMAKE)
fs_legacy_container(OS debian VERSION 11 BOOTSTRAP_CMAKE)
fs_legacy_container(OS debian VERSION 12)
fs_legacy_container(OS fedora VERSION 37)
fs_legacy_container(OS fedora VERSION 38)
fs_legacy_container(OS fedora VERSION 39)
fs_legacy_container(OS ubuntu VERSION 20.04 BOOTSTRAP_CMAKE)
fs_legacy_container(OS ubuntu VERSION 22.04)


add_custom_target(all-legacy-containers DEPENDS ${legacy_containers})

list(TRANSFORM legacy_containers
     PREPEND "${CMAKE_CURRENT_BINARY_DIR}/"
     OUTPUT_VARIABLE legacy_containers_for_install)

install(FILES ${legacy_containers_for_install}
        DESTINATION "${PROJECT_CONTAINER_DIR}"
        COMPONENT containers
        EXCLUDE_FROM_ALL)
