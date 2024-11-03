# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

cmake_minimum_required(VERSION 3.25)
get_filename_component(SCRIPT_NAME "${CMAKE_CURRENT_LIST_FILE}" NAME_WE)
set(CMAKE_MESSAGE_INDENT "[${VERSION}][${LANGUAGE}] ")
set(CMAKE_MESSAGE_INDENT_BACKUP "${CMAKE_MESSAGE_INDENT}")
message(STATUS "-------------------- ${SCRIPT_NAME} --------------------")


set(CMAKE_MODULE_PATH   "${PROJ_CMAKE_MODULES_DIR}")
find_package(Crowdin    MODULE REQUIRED)
include(LogUtils)


message(STATUS "Running 'crowdin upload sources' command to upload .pot files...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${Crowdin_EXECUTABLE} upload sources
            --branch ${VERSION}
            --config ${TMS_CONFIG_FILE_PATH}
            --no-progress
            --verbose
    WORKING_DIRECTORY ${PROJ_L10N_VERSION_DIR}
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    COMMAND_ERROR_IS_FATAL ANY)
message("")
restore_cmake_message_indent()
