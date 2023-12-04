# gnu compatibility,
# see https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html
# this is used to retrieve portable install paths
# e.g. some platforms install libraries in lib, others in lib64
include(GNUInstallDirs)

if(NOT DEFINED TOP_PROJECT_NAME)
  message(FATAL_ERROR "Variable TOP_PROJECT_NAME is not defined.")
endif()

set(MODULEFILE_DIR "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}/modulefiles/${TOP_PROJECT_NAME_LC}-dependencies")
file(MAKE_DIRECTORY ${MODULEFILE_DIR})
configure_file(cmake/modulefile.in "${MODULEFILE_DIR}/1.0")
