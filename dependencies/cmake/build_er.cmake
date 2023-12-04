#
# Option to use git (instead of tarball release) for downloading er
#
# Turn ON by default, to retrieve ER.
#
option(${TOP_PROJECT_NAME}_ER_USE_GIT "Turn ON if you want to use git to download ER sources (default: OFF)" OFF)

set(CMAKE_BUILD_TYPE_ER "Release" CACHE STRING "ER build type")
if (NOT CMAKE_BUILD_TYPE_ER)
  message(STATUS "Setting ER build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE_ER "Release" CACHE STRING
    "Choose the type of build, options are: Debug, Release, RelWithDebInfo and MinSizeRel." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE_ER PROPERTY STRINGS
    "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif ()

#
# check if user requested a build of ER
#
if(${TOP_PROJECT_NAME}_ER_BUILD)

  message("[kokkos-resilience / ER] Building ER from source")

  set_property(DIRECTORY PROPERTY EP_BASE ${CMAKE_BINARY_DIR}/external/er)

  # set install path
  set (ER_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})

  # set minimal cmake options
  set(cmake_er_args
    -DCMAKE_INSTALL_PREFIX:PATH=${ER_INSTALL_PREFIX}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE_ER}
    -DBUILD_SHARED_LIBS=ON
    )

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
  # there are 2 ways to retrieve ER sources:
  #
  # 1. Use git to perform a local clone of the github ER repository
  # 2. Use an archive file, variable ${TOP_PROJECT_NAME}_ER_SOURCE_ARCHIVE is used to specify
  #    the full path or remote URL to that archive.
  #    This variable can be set on the cmake command line, e.g.
  #    `-D${TOP_PROJECT_NAME}_ER_SOURCE_ARCHIVE=$HOME/er-0.4.0.tar.gz`
  #    Be careful to provide a tarball with ER.

  # define the default ER version used to download source from github
  if (NOT DEFINED ${TOP_PROJECT_NAME}_ER_USE_GIT_ER_VERSION)
    set(${TOP_PROJECT_NAME}_ER_USE_GIT_ER_VERSION 0.4.0)
  endif()

  #
  if (NOT DEFINED ${TOP_PROJECT_NAME}_ER_SOURCE_ARCHIVE)
    set(${TOP_PROJECT_NAME}_ER_SOURCE_ARCHIVE https://github.com/ECP-VeloC/er/archive/refs/tags/v0.4.0.tar.gz CACHE STRING "ER source archive (URL or local filepath).")
    message("Using default archive: ${${TOP_PROJECT_NAME}_ER_SOURCE_ARCHIVE}")
  endif()

  message(STATUS "ER build with cmake command line : ${cmake_er_args}")

  #
  # Use cmake to build ER
  #
  if (${TOP_PROJECT_NAME}_ER_USE_GIT)
    message("Building ER with cmake using github repository with tag version ${${TOP_PROJECT_NAME}_ER_USE_GIT_ER_VERSION}")
    ExternalProject_Add( er_external
      GIT_REPOSITORY https://github.com/ECP-VeloC/er.git
      GIT_TAG 0.4.0
      CMAKE_ARGS ${cmake_er_args}
      BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j 8
      LOG_CONFIGURE 1
      LOG_BUILD 1
      LOG_INSTALL 1
      )
  else()
    message("Building ER with cmake using source archive ${${TOP_PROJECT_NAME}_ER_SOURCE_ARCHIVE}")

    ExternalProject_Add( er_external
      URL ${${TOP_PROJECT_NAME}_ER_SOURCE_ARCHIVE}
      CMAKE_ARGS ${cmake_er_args}
      BUILD_COMMAND ${CMAKE_MAKE_PROGRAM} -j 8
      LOG_CONFIGURE 1
      LOG_BUILD 1
      LOG_INSTALL 1
      )
  endif()

  message("[kokkos-resilience / ER] ER will be installed into ${ER_INSTALL_PREFIX}")

endif(${TOP_PROJECT_NAME}_ER_BUILD)
