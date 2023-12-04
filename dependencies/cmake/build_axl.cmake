#
# Option to use git (instead of tarball release) for downloading er
#
# Turn ON by default, to retrieve AXL.
#
option(${TOP_PROJECT_NAME}_AXL_USE_GIT "Turn ON if you want to use git to download AXL sources (default: OFF)" OFF)

set(CMAKE_BUILD_TYPE_AXL "Release" CACHE STRING "AXL build type")
if (NOT CMAKE_BUILD_TYPE_AXL)
  message(STATUS "Setting AXL build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE_AXL "Release" CACHE STRING
    "Choose the type of build, options are: Debug, Release, RelWithDebInfo and MinSizeRel." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE_AXL PROPERTY STRINGS
    "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif ()

#
# check if user requested a build of AXL
#
if(${TOP_PROJECT_NAME}_AXL_BUILD)

  message("[kokkos-resilience / AXL] Building AXL from source")

  set_property(DIRECTORY PROPERTY EP_BASE ${CMAKE_BINARY_DIR}/external/axl)

  # set install path
  set (AXL_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})

  # set minimal cmake options
  set(cmake_axl_args
    -DCMAKE_INSTALL_PREFIX:PATH=${AXL_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE_AXL}
    -DBUILD_SHARED_LIBS=ON
    )

  find_package(MPI COMPONENTS C CXX)
  if (MPI_FOUND)
    list(APPEND cmake_axl_args -DMPI=ON)
  else()
    message(WARNING "MPI not found. MPI support not available in AXL.")
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
  # there are 2 ways to retrieve AXL sources:
  #
  # 1. Use git to perform a local clone of the github AXL repository
  # 2. Use an archive file, variable ${TOP_PROJECT_NAME}_AXL_SOURCE_ARCHIVE is used to specify
  #    the full path or remote URL to that archive.
  #    This variable can be set on the cmake command line, e.g.
  #    `-D${TOP_PROJECT_NAME}_AXL_SOURCE_ARCHIVE=$HOME/axl-0.8.0.tar.gz`
  #    Be careful to provide a tarball with AXL.

  # define the default AXL version used to download source from github
  if (NOT DEFINED ${TOP_PROJECT_NAME}_AXL_USE_GIT_AXL_VERSION)
    set(${TOP_PROJECT_NAME}_AXL_USE_GIT_AXL_VERSION 0.8.0)
  endif()

  #
  if (NOT DEFINED ${TOP_PROJECT_NAME}_AXL_SOURCE_ARCHIVE)
    set(${TOP_PROJECT_NAME}_AXL_SOURCE_ARCHIVE https://github.com/ECP-VeloC/axl/archive/refs/tags/v0.8.0.tar.gz CACHE STRING "AXL source archive (URL or local filepath).")
    message("Using default archive: ${${TOP_PROJECT_NAME}_AXL_SOURCE_ARCHIVE}")
  endif()

  message(STATUS "AXL build with cmake command line : ${cmake_axl_args}")

  #
  # Use cmake to build AXL
  #
  if (${TOP_PROJECT_NAME}_AXL_USE_GIT)
    message("Building AXL with cmake using github repository with tag version ${${TOP_PROJECT_NAME}_AXL_USE_GIT_AXL_VERSION}")
    ExternalProject_Add( axl_external
      GIT_REPOSITORY https://github.com/ECP-VeloC/axl.git
      GIT_TAG 0.8.0
      CMAKE_ARGS ${cmake_axl_args}
      BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j 8
      LOG_CONFIGURE 1
      LOG_BUILD 1
      LOG_INSTALL 1
      )
  else()
    message("Building AXL with cmake using source archive ${${TOP_PROJECT_NAME}_AXL_SOURCE_ARCHIVE}")

    ExternalProject_Add( axl_external
      URL ${${TOP_PROJECT_NAME}_AXL_SOURCE_ARCHIVE}
      CMAKE_ARGS ${cmake_axl_args}
      BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j 8
      LOG_CONFIGURE 1
      LOG_BUILD 1
      LOG_INSTALL 1
      )
  endif()

  message("[kokkos-resilience / AXL] AXL will be installed into ${AXL_INSTALL_PREFIX}")

endif(${TOP_PROJECT_NAME}_AXL_BUILD)
