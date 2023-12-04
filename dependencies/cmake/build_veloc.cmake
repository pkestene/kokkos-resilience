#
# Option to use git (instead of tarball release) for downloading er
#
# Turn ON by default, to retrieve VELOC.
#
option(${TOP_PROJECT_NAME}_VELOC_USE_GIT "Turn ON if you want to use git to download VELOC sources (default: OFF)" OFF)

set(CMAKE_BUILD_TYPE_VELOC "Release" CACHE STRING "VELOC build type")
if (NOT CMAKE_BUILD_TYPE_VELOC)
  message(STATUS "Setting VELOC build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE_VELOC "Release" CACHE STRING
    "Choose the type of build, options are: Debug, Release, RelWithDebInfo and MinSizeRel." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE_VELOC PROPERTY STRINGS
    "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif ()

#
# check if user requested a build of VELOC
#
if(${TOP_PROJECT_NAME}_VELOC_BUILD)

  message("[kokkos-resilience / VELOC] Building VELOC from source")

  set_property(DIRECTORY PROPERTY EP_BASE ${CMAKE_BINARY_DIR}/external/veloc)

  # set install path
  set (VELOC_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})

  # set minimal cmake options
  set(cmake_veloc_args
    -DCMAKE_INSTALL_PREFIX:PATH=${VELOC_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE_VELOC}
    -DBUILD_SHARED_LIBS=ON
    )

  find_package(MPI COMPONENTS C CXX)
  if (MPI_FOUND)
    list(APPEND cmake_veloc_args -DMPI=ON)
  else()
    message(WARNING "MPI not found. MPI support not available in VELOC.")
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
  # there are 2 ways to retrieve VELOC sources:
  #
  # 1. Use git to perform a local clone of the github VELOC repository
  # 2. Use an archive file, variable ${TOP_PROJECT_NAME}_VELOC_SOURCE_ARCHIVE is used to specify
  #    the full path or remote URL to that archive.
  #    This variable can be set on the cmake command line, e.g.
  #    `-D${TOP_PROJECT_NAME}_VELOC_SOURCE_ARCHIVE=$HOME/veloc-1.7.tar.gz`
  #    Be careful to provide a tarball with VELOC.

  # define the default VELOC version used to download source from github
  if (NOT DEFINED ${TOP_PROJECT_NAME}_VELOC_USE_GIT_VELOC_VERSION)
    set(${TOP_PROJECT_NAME}_VELOC_USE_GIT_VELOC_VERSION 1.7)
  endif()

  #
  if (NOT DEFINED ${TOP_PROJECT_NAME}_VELOC_SOURCE_ARCHIVE)
    set(${TOP_PROJECT_NAME}_VELOC_SOURCE_ARCHIVE https://github.com/ECP-VeloC/veloc/archive/refs/tags/veloc-1.7.tar.gz CACHE STRING "VELOC source archive (URL or local filepath).")
    message("Using default archive: ${${TOP_PROJECT_NAME}_VELOC_SOURCE_ARCHIVE}")
  endif()

  message(STATUS "VELOC build with cmake command line : ${cmake_veloc_args}")

  #
  # Use cmake to build VELOC
  #
  if (${TOP_PROJECT_NAME}_VELOC_USE_GIT)
    message("Building VELOC with cmake using github repository with tag version ${${TOP_PROJECT_NAME}_VELOC_USE_GIT_VELOC_VERSION}")
    ExternalProject_Add( veloc_external
      GIT_REPOSITORY https://github.com/ECP-VeloC/veloc.git
      GIT_TAG 1.7
      CMAKE_ARGS ${cmake_veloc_args}
      BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j 8
      LOG_CONFIGURE 1
      LOG_BUILD 1
      LOG_INSTALL 1
      )
  else()
    message("Building VELOC with cmake using source archive ${${TOP_PROJECT_NAME}_VELOC_SOURCE_ARCHIVE}")

    ExternalProject_Add( veloc_external
      URL ${${TOP_PROJECT_NAME}_VELOC_SOURCE_ARCHIVE}
      CMAKE_ARGS ${cmake_veloc_args}
      BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j 8
      LOG_CONFIGURE 1
      LOG_BUILD 1
      LOG_INSTALL 1
      )
  endif()

  message("[kokkos-resilience / VELOC] VELOC will be installed into ${VELOC_INSTALL_PREFIX}")

endif(${TOP_PROJECT_NAME}_VELOC_BUILD)
