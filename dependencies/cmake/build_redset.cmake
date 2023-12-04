#
# Option to use git (instead of tarball release) for downloading er
#
# Turn ON by default, to retrieve REDSET.
#
option(${TOP_PROJECT_NAME}_REDSET_USE_GIT "Turn ON if you want to use git to download REDSET sources (default: OFF)" OFF)

set(CMAKE_BUILD_TYPE_REDSET "Release" CACHE STRING "REDSET build type")
if (NOT CMAKE_BUILD_TYPE_REDSET)
  message(STATUS "Setting REDSET build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE_REDSET "Release" CACHE STRING
    "Choose the type of build, options are: Debug, Release, RelWithDebInfo and MinSizeRel." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE_REDSET PROPERTY STRINGS
    "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif ()

#
# check if user requested a build of REDSET
#
if(${TOP_PROJECT_NAME}_REDSET_BUILD)

  message("[kokkos-resilience / REDSET] Building REDSET from source")

  set_property(DIRECTORY PROPERTY EP_BASE ${CMAKE_BINARY_DIR}/external/redset)

  # set install path
  set (REDSET_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})

  # set minimal cmake options
  set(cmake_redset_args
    -DCMAKE_INSTALL_PREFIX:PATH=${REDSET_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE_REDSET}
    -DBUILD_SHARED_LIBS=ON
    )

  find_package(MPI COMPONENTS C CXX)
  if (MPI_FOUND)
    list(APPEND cmake_redset_args -DMPI=ON)
  else()
    message(WARNING "MPI not found. MPI support not available in REDSET.")
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
  # there are 2 ways to retrieve REDSET sources:
  #
  # 1. Use git to perform a local clone of the github REDSET repository
  # 2. Use an archive file, variable ${TOP_PROJECT_NAME}_REDSET_SOURCE_ARCHIVE is used to specify
  #    the full path or remote URL to that archive.
  #    This variable can be set on the cmake command line, e.g.
  #    `-D${TOP_PROJECT_NAME}_REDSET_SOURCE_ARCHIVE=$HOME/redset-0.3.0.tar.gz`
  #    Be careful to provide a tarball with REDSET.

  # define the default REDSET version used to download source from github
  if (NOT DEFINED ${TOP_PROJECT_NAME}_REDSET_USE_GIT_REDSET_VERSION)
    set(${TOP_PROJECT_NAME}_REDSET_USE_GIT_REDSET_VERSION 0.3.0)
  endif()

  #
  if (NOT DEFINED ${TOP_PROJECT_NAME}_REDSET_SOURCE_ARCHIVE)
    set(${TOP_PROJECT_NAME}_REDSET_SOURCE_ARCHIVE https://github.com/ECP-VeloC/redset/archive/refs/tags/v0.3.0.tar.gz CACHE STRING "REDSET source archive (URL or local filepath).")
    message("Using default archive: ${${TOP_PROJECT_NAME}_REDSET_SOURCE_ARCHIVE}")
  endif()

  message(STATUS "REDSET build with cmake command line : ${cmake_redset_args}")

  #
  # Use cmake to build REDSET
  #
  if (${TOP_PROJECT_NAME}_REDSET_USE_GIT)
    message("Building REDSET with cmake using github repository with tag version ${${TOP_PROJECT_NAME}_REDSET_USE_GIT_REDSET_VERSION}")
    ExternalProject_Add( redset_external
      GIT_REPOSITORY https://github.com/ECP-VeloC/redset.git
      GIT_TAG 0.3.0
      CMAKE_ARGS ${cmake_redset_args}
      BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j 8
      LOG_CONFIGURE 1
      LOG_BUILD 1
      LOG_INSTALL 1
      )
  else()
    message("Building REDSET with cmake using source archive ${${TOP_PROJECT_NAME}_REDSET_SOURCE_ARCHIVE}")

    ExternalProject_Add( redset_external
      URL ${${TOP_PROJECT_NAME}_REDSET_SOURCE_ARCHIVE}
      CMAKE_ARGS ${cmake_redset_args}
      BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j 8
      LOG_CONFIGURE 1
      LOG_BUILD 1
      LOG_INSTALL 1
      )
  endif()

  message("[kokkos-resilience / REDSET] REDSET will be installed into ${REDSET_INSTALL_PREFIX}")

endif(${TOP_PROJECT_NAME}_REDSET_BUILD)
