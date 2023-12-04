#
# Option to use git (instead of tarball release) for downloading er
#
# Turn ON by default, to retrieve KVTREE.
#
option(${TOP_PROJECT_NAME}_KVTREE_USE_GIT "Turn ON if you want to use git to download KVTREE sources (default: OFF)" OFF)

set(CMAKE_BUILD_TYPE_KVTREE "Release" CACHE STRING "KVTREE build type")
if (NOT CMAKE_BUILD_TYPE_KVTREE)
  message(STATUS "Setting KVTREE build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE_KVTREE "Release" CACHE STRING
    "Choose the type of build, options are: Debug, Release, RelWithDebInfo and MinSizeRel." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE_KVTREE PROPERTY STRINGS
    "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif ()

#
# check if user requested a build of KVTREE
#
if(${TOP_PROJECT_NAME}_KVTREE_BUILD)

  message("[kokkos-resilience / KVTREE] Building KVTREE from source")

  set_property(DIRECTORY PROPERTY EP_BASE ${CMAKE_BINARY_DIR}/external/kvtree)

  # set install path
  set (KVTREE_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})

  # set minimal cmake options
  set(cmake_kvtree_args
    -DCMAKE_INSTALL_PREFIX:PATH=${KVTREE_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE_KVTREE}
    -DBUILD_SHARED_LIBS=ON
    )

  find_package(MPI COMPONENTS C CXX)
  if (MPI_FOUND)
    list(APPEND cmake_kvtree_args -DMPI=ON)
  else()
    message(WARNING "MPI not found. MPI support not available in KVTREE.")
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
  # there are 2 ways to retrieve KVTREE sources:
  #
  # 1. Use git to perform a local clone of the github KVTREE repository
  # 2. Use an archive file, variable ${TOP_PROJECT_NAME}_KVTREE_SOURCE_ARCHIVE is used to specify
  #    the full path or remote URL to that archive.
  #    This variable can be set on the cmake command line, e.g.
  #    `-D${TOP_PROJECT_NAME}_KVTREE_SOURCE_ARCHIVE=$HOME/kvtree-1.4.0.tar.gz`
  #    Be careful to provide a tarball with KVTREE.

  # define the default KVTREE version used to download source from github
  if (NOT DEFINED ${TOP_PROJECT_NAME}_KVTREE_USE_GIT_KVTREE_VERSION)
    set(${TOP_PROJECT_NAME}_KVTREE_USE_GIT_KVTREE_VERSION 1.4.0)
  endif()

  #
  if (NOT DEFINED ${TOP_PROJECT_NAME}_KVTREE_SOURCE_ARCHIVE)
    set(${TOP_PROJECT_NAME}_KVTREE_SOURCE_ARCHIVE https://github.com/ECP-VeloC/KVTree/archive/refs/tags/v1.4.0.tar.gz CACHE STRING "KVTREE source archive (URL or local filepath).")
    message("Using default archive: ${${TOP_PROJECT_NAME}_KVTREE_SOURCE_ARCHIVE}")
  endif()

  message(STATUS "KVTREE build with cmake command line : ${cmake_kvtree_args}")

  #
  # Use cmake to build KVTREE
  #
  if (${TOP_PROJECT_NAME}_KVTREE_USE_GIT)
    message("Building KVTREE with cmake using github repository with tag version ${${TOP_PROJECT_NAME}_KVTREE_USE_GIT_KVTREE_VERSION}")
    ExternalProject_Add( kvtree_external
      GIT_REPOSITORY https://github.com/ECP-VeloC/KVTree.git
      GIT_TAG 1.4.0
      CMAKE_ARGS ${cmake_kvtree_args}
      BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j 8
      LOG_CONFIGURE 1
      LOG_BUILD 1
      LOG_INSTALL 1
      )
  else()
    message("Building KVTREE with cmake using source archive ${${TOP_PROJECT_NAME}_KVTREE_SOURCE_ARCHIVE}")

    ExternalProject_Add( kvtree_external
      URL ${${TOP_PROJECT_NAME}_KVTREE_SOURCE_ARCHIVE}
      CMAKE_ARGS ${cmake_kvtree_args}
      BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j 8
      LOG_CONFIGURE 1
      LOG_BUILD 1
      LOG_INSTALL 1
      )
  endif()

  message("[kokkos-resilience / KVTREE] KVTREE will be installed into ${KVTREE_INSTALL_PREFIX}")

endif(${TOP_PROJECT_NAME}_KVTREE_BUILD)
