# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

get_filename_component(WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)
set(VERSION_LIST
    "v3.0"  "v3.1"  "v3.2"  "v3.3"  "v3.4"  "v3.5"  "v3.6"  "v3.7"  "v3.8"  "v3.9"
    "v3.10" "v3.11" "v3.12" "v3.13" "v3.14" "v3.15" "v3.16" "v3.17" "v3.18" "v3.19"
    "v3.20" "v3.21" "v3.22" "v3.23" "v3.24" "v3.25" "v3.26" "v3.27" "v3.28" "v3.29"
    "latest" "git-master")
foreach(_VERSION ${VERSION_LIST})
    message(STATUS "Configuring with '${_VERSION}' version...")
    execute_process(
        COMMAND ${CMAKE_COMMAND}
                --preset all
                -D VERSION=${_VERSION}
        WORKING_DIRECTORY ${WORKING_DIRECTORY}
        OUTPUT_QUIET
        ERROR_QUIET)
endforeach()
unset(_VERSION)
