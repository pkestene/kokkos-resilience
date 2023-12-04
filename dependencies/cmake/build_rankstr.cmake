#
# Option to use git (instead of tarball release) for downloading er
#
# Turn ON by default, to retrieve RANKSTR.
#
option(${TOP_PROJECT_NAME}_RANKSTR_USE_GIT "Turn ON if you want to use git to download RANKSTR sources (default: OFF)" OFF)

set(CMAKE_BUILD_TYPE_RANKSTR "Release" CACHE STRING "RANKSTR build type")
if (NOT CMAKE_BUILD_TYPE_RANKSTR)
  message(STATUS "Setting RANKSTR build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE_RANKSTR "Release" CACHE STRING
    "Choose the type of build, options are: Debug, Release, RelWithDebInfo and MinSizeRel." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE_RANKSTR PROPERTY STRINGS
    "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif ()

#
# check if user requested a build of RANKSTR
#
if(${TOP_PROJECT_NAME}_RANKSTR_BUILD)

  message("[kokkos-resilience / RANKSTR] Building RANKSTR from source")

  set_property(DIRECTORY PROPERTY EP_BASE ${CMAKE_BINARY_DIR}/external/rankstr)

  # set install path
  set (RANKSTR_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})

  # set minimal cmake options
  set(cmake_rankstr_args
    -DCMAKE_INSTALL_PREFIX:PATH=${RANKSTR_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE_RANKSTR}
    -DBUILD_SHARED_LIBS=ON
    )

  find_package(MPI COMPONENTS C CXX)
  if (MPI_FOUND)
    list(APPEND cmake_rankstr_args -DMPI=ON)
  else()
    message(WARNING "MPI not found. MPI support not available in RANKSTR.")
  endif()

  #
  # Make ExternalProject macro available
  #
  include(ExternalProject)

  # gnu compatibility,
  # see https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html
  # this is used to retrieve portable install paths
  # e.g. some platforms install libraries in lib, others in lib64
  include(GNUInstallDirs)

  #
  # there are 2 ways to retrieve RANKSTR sources:
  #
  # 1. Use git to perform a local clone of the github RANKSTR repository
  # 2. Use an archive file, variable ${TOP_PROJECT_NAME}_RANKSTR_SOURCE_ARCHIVE is used to specify
  #    the full path or remote URL to that archive.
  #    This variable can be set on the cmake command line, e.g.
  #    `-D${TOP_PROJECT_NAME}_RANKSTR_SOURCE_ARCHIVE=$HOME/rankstr-0.3.0.tar.gz`
  #    Be careful to provide a tarball with RANKSTR.

  # define the default RANKSTR version used to download source from github
  if (NOT DEFINED ${TOP_PROJECT_NAME}_RANKSTR_USE_GIT_RANKSTR_VERSION)
    set(${TOP_PROJECT_NAME}_RANKSTR_USE_GIT_RANKSTR_VERSION 0.3.0)
  endif()

  #
  if (NOT DEFINED ${TOP_PROJECT_NAME}_RANKSTR_SOURCE_ARCHIVE)
    set(${TOP_PROJECT_NAME}_RANKSTR_SOURCE_ARCHIVE https://github.com/ECP-VeloC/rankstr/archive/refs/tags/v0.3.0.tar.gz CACHE STRING "RANKSTR source archive (URL or local filepath).")
    message("Using default archive: ${${TOP_PROJECT_NAME}_RANKSTR_SOURCE_ARCHIVE}")
  endif()

  message(STATUS "RANKSTR build with cmake command line : ${cmake_rankstr_args}")

  #
  # Use cmake to build RANKSTR
  #
  if (${TOP_PROJECT_NAME}_RANKSTR_USE_GIT)
    message("Building RANKSTR with cmake using github repository with tag version ${${TOP_PROJECT_NAME}_RANKSTR_USE_GIT_RANKSTR_VERSION}")
    ExternalProject_Add( rankstr_external
      GIT_REPOSITORY https://github.com/ECP-VeloC/rankstr.git
      GIT_TAG 0.3.0
      CMAKE_ARGS ${cmake_rankstr_args}
      BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j 8
      LOG_CONFIGURE 1
      LOG_BUILD 1
      LOG_INSTALL 1
      )
  else()
    message("Building RANKSTR with cmake using source archive ${${TOP_PROJECT_NAME}_RANKSTR_SOURCE_ARCHIVE}")

    ExternalProject_Add( rankstr_external
      URL ${${TOP_PROJECT_NAME}_RANKSTR_SOURCE_ARCHIVE}
      CMAKE_ARGS ${cmake_rankstr_args}
      BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j 8
      LOG_CONFIGURE 1
      LOG_BUILD 1
      LOG_INSTALL 1
      )
  endif()

  message("[kokkos-resilience / RANKSTR] RANKSTR will be installed into ${RANKSTR_INSTALL_PREFIX}")

endif(${TOP_PROJECT_NAME}_RANKSTR_BUILD)
