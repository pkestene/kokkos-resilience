message(STATUS "Building kokkos-resilience dependencies")

#
# Do we want to build KVTREE (https://github.com/ECP-VeloC/KVTree) ?
#
option(${TOP_PROJECT_NAME}_KVTREE_BUILD "Turn ON if you want to build KVTREE (default: ON)" ON)
include(cmake/build_kvtree.cmake)

#
# Do we want to build RANKSTR (https://github.com/ECP-VeloC/rankstr) ?
#
option(${TOP_PROJECT_NAME}_RANKSTR_BUILD "Turn ON if you want to build RANKSTR (default: ON)" ON)
include(cmake/build_rankstr.cmake)

#
# Do we want to build REDSET (https://github.com/ECP-VeloC/redset) ?
#
option(${TOP_PROJECT_NAME}_REDSET_BUILD "Turn ON if you want to build REDSET (default: ON)" ON)
include(cmake/build_redset.cmake)

#
# Do we want to build SHUFFILE (https://github.com/ECP-VeloC/shuffile) ?
#
option(${TOP_PROJECT_NAME}_SHUFFILE_BUILD "Turn ON if you want to build SHUFFILE (default: ON)" ON)
include(cmake/build_shuffile.cmake)

#
# Do we want to build ER (https://github.com/ECP-VeloC/er) ?
#
option(${TOP_PROJECT_NAME}_ER_BUILD "Turn ON if you want to build ER (default: ON)" ON)
include(cmake/build_er.cmake)

#
# Do we want to build AXL (https://github.com/ECP-VeloC/AXL) ?
#
option(${TOP_PROJECT_NAME}_AXL_BUILD "Turn ON if you want to build AXL (default: ON)" ON)
include(cmake/build_axl.cmake)

#
# Do we want to build VELOC (https://github.com/ECP-VeloC/VELOC) ?
#
option(${TOP_PROJECT_NAME}_VELOC_BUILD "Turn ON if you want to build VELOC (default: ON)" ON)
include(cmake/build_veloc.cmake)
