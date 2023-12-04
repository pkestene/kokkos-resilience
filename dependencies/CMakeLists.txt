cmake_minimum_required(VERSION 3.18)

#
# Allow find_package() to use <PackageName>_ROOT variables,
# either cmake variable or environment variables
# see https://cmake.org/cmake/help/latest/policy/CMP0074.html
#
if(NOT CMAKE_VERSION VERSION_LESS 3.12)
  cmake_policy(SET CMP0074 NEW)
endif()

project(kokkos-resilience_dependencies
  LANGUAGES C CXX
  VERSION 0.1.0
  DESCRIPTION "Helper cmake project to build kokkos-resilience dependencies (ER, AXL and VELOC).")

set(TOP_PROJECT_NAME kokkos-resilience)
string(TOLOWER ${TOP_PROJECT_NAME} TOP_PROJECT_NAME_LC)

#
# Enforce user to use a build directory outside of source tree
#
include(cmake/prevent_build_in_source.cmake)
prevent_build_in_source()

#
# Setup default install path
#
# Notice: cmake sets the default install directory to /usr/local which is usually not writable
# by a normal user. So we change this default to be ~/.kokkos-resilience_dependencies
# users can overwrite this default by using e.g. "-DCMAKE_INSTALL_PREFIX=/my/custom/dir"
#
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  # will not take effect without FORCE
  set(CMAKE_INSTALL_PREFIX "$ENV{HOME}/.kokkos-resilience_dependencies" CACHE PATH "Path where kokkos-resilience dependencies will be installed" FORCE)
endif()

#
# Set default compile optimization flag used for all dependencies.
# Usually Release is fine, most of the time if you need to debug, only kokkos-resilience build need debug.
#
if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(DEFAULT_BUILD_TYPE "Release")
  message(STATUS "Setting build type to '${DEFAULT_BUILD_TYPE}' as none was specified.")
  set(CMAKE_BUILD_TYPE "${DEFAULT_BUILD_TYPE}" CACHE STRING
    "Choose the type of build, options are: Debug, Release, RelWithDebInfo and MinSizeRel." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif ()

#
# setup the list of dependencies to build
#
include(cmake/build_dependencies.cmake)

#
# create and install a modulefile to ease the use of kokkos-resilience dependencies
#
include(cmake/modulefiles.cmake)

##################### PRINT CONFIGURE STATUS ######################
message("//===================================================")
message("// ${PROJECT_NAME} build configuration:")
message("// ${PROJECT_NAME} version : ${PROJECT_VERSION}")
message("//===================================================")
message("  CMake version          : ${CMAKE_VERSION}")
if (NOT CMAKE_BUILD_TYPE)
  message("  CMake build type        : NOT SET !")
else()
  message("  CMake build type        : ${CMAKE_BUILD_TYPE}")
endif()
message("  CMake install prefix   : ${CMAKE_INSTALL_PREFIX}")
message("  CMake system processor : ${CMAKE_SYSTEM_PROCESSOR}")
message("  CMake system name (OS) : ${CMAKE_SYSTEM_NAME}")
message("")

message(STATUS "List of kokkos-resilience dependencies :")
message("")


message("   ${TOP_PROJECT_NAME}_KVTREE_BUILD   : ${${TOP_PROJECT_NAME}_KVTREE_BUILD}")
message("   ${TOP_PROJECT_NAME}_RANKSTR_BUILD  : ${${TOP_PROJECT_NAME}_RANKSTR_BUILD}")
message("   ${TOP_PROJECT_NAME}_REDSET_BUILD   : ${${TOP_PROJECT_NAME}_REDSET_BUILD}")
message("   ${TOP_PROJECT_NAME}_SHUFFILE_BUILD : ${${TOP_PROJECT_NAME}_SHUFFILE_BUILD}")
message("   ${TOP_PROJECT_NAME}_ER_BUILD       : ${${TOP_PROJECT_NAME}_ER_BUILD}")
message("   ${TOP_PROJECT_NAME}_AXL_BUILD      : ${${TOP_PROJECT_NAME}_AXL_BUILD}")
message("   ${TOP_PROJECT_NAME}_VELOC_BUILD    : ${${TOP_PROJECT_NAME}_VELOC_BUILD}")

message("")

message("To actually use these dependencies, just do:")
message("")
message("   module use ${CMAKE_INSTALL_PREFIX}/share/modulefiles")
message("   module load ${PROJECT_NAME}/1.0")
message("")
