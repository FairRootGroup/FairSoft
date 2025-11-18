# reclaim-diskspace.cmake
# Remove package build/source directories after install to reclaim disk space
# Expected variables: PACKAGE_NAME, PKG_BUILD_DIR, PKG_SOURCE_DIR, CMAKE_BINARY_DIR

if(NOT DEFINED PACKAGE_NAME OR NOT DEFINED PKG_BUILD_DIR OR NOT DEFINED PKG_SOURCE_DIR)
  message(FATAL_ERROR "PACKAGE_NAME, PKG_BUILD_DIR, and PKG_SOURCE_DIR must be defined")
endif()

# Helper function to measure directory size in MB
function(measure_dir_size_mb dir out_var out_success)
  set(${out_success} FALSE PARENT_SCOPE)
  set(${out_var} 0 PARENT_SCOPE)
  if(UNIX)
    find_program(DU_EXECUTABLE du)
    if(DU_EXECUTABLE)
      execute_process(
        COMMAND ${DU_EXECUTABLE} -sk "${dir}"
        OUTPUT_VARIABLE du_output
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
      )
      if(du_output)
        string(REGEX REPLACE "^([0-9]+).*" "\\1" size_kb "${du_output}")
        math(EXPR size_mb "${size_kb} / 1024")
        set(${out_var} ${size_mb} PARENT_SCOPE)
        set(${out_success} TRUE PARENT_SCOPE)
      endif()
    endif()
  endif()
endfunction()

# Measure sizes before removal
measure_dir_size_mb("${PKG_BUILD_DIR}" build_mb build_ok)
measure_dir_size_mb("${PKG_SOURCE_DIR}" source_mb source_ok)

if(build_ok AND source_ok)
  math(EXPR total_mb "${build_mb} + ${source_mb}")
  message(STATUS "[${PACKAGE_NAME}] Reclaiming ~${total_mb} MB (build: ${build_mb}, source: ${source_mb})")
elseif(build_ok)
  message(STATUS "[${PACKAGE_NAME}] Reclaiming ~${build_mb} MB")
elseif(source_ok)
  message(STATUS "[${PACKAGE_NAME}] Reclaiming ~${source_mb} MB")
else()
  message(STATUS "[${PACKAGE_NAME}] Removing package directories...")
endif()

# Remove package directories
execute_process(COMMAND ${CMAKE_COMMAND} -E rm -rf "${PKG_BUILD_DIR}" RESULT_VARIABLE build_rm)
execute_process(COMMAND ${CMAKE_COMMAND} -E rm -rf "${PKG_SOURCE_DIR}" RESULT_VARIABLE source_rm)

if(NOT build_rm EQUAL 0)
  message(WARNING "[${PACKAGE_NAME}] Failed to remove package build directory")
endif()
if(NOT source_rm EQUAL 0)
  message(WARNING "[${PACKAGE_NAME}] Failed to remove package source directory")
endif()

# Report total build tree size
if(DEFINED CMAKE_BINARY_DIR)
  measure_dir_size_mb("${CMAKE_BINARY_DIR}" tree_mb tree_ok)
  if(tree_ok)
    message(STATUS "[${PACKAGE_NAME}] Build tree size: ${tree_mb} MB")
  endif()
endif()
