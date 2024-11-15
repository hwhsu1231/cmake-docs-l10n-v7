# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

cmake_minimum_required(VERSION 3.25)
get_filename_component(SCRIPT_NAME "${CMAKE_CURRENT_LIST_FILE}" NAME_WE)
set(CMAKE_MESSAGE_INDENT "[${VERSION}][${LANGUAGE}] ")
set(CMAKE_MESSAGE_INDENT_BACKUP "${CMAKE_MESSAGE_INDENT}")
message(STATUS "-------------------- ${SCRIPT_NAME} --------------------")


set(CMAKE_MODULE_PATH   "${PROJ_CMAKE_MODULES_DIR}")
find_package(Git        MODULE REQUIRED)
include(GitUtils)
include(JsonUtils)
include(LogUtils)


message(STATUS "Cloning the repository to '${PROJ_OUT_REPO_DIR}/'...")
remove_cmake_message_indent()
message("")
if(NOT EXISTS "${PROJ_OUT_REPO_DIR}/.git")
    file(MAKE_DIRECTORY "${PROJ_OUT_REPO_DIR}")
    execute_process(
        COMMAND ${Git_EXECUTABLE} clone
                --depth=1
                --single-branch
                --recurse-submodules
                --shallow-submodules
                ${REMOTE_URL_OF_DOCS}
                ${PROJ_OUT_REPO_DIR}
        WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
else()
    execute_process(
        COMMAND ${Git_EXECUTABLE} remote
        WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
        OUTPUT_VARIABLE REMOTE_NAME OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process(
        COMMAND ${Git_EXECUTABLE} remote get-url ${REMOTE_NAME}
        WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
        OUTPUT_VARIABLE CURRENT_REMOTE_URL OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (NOT "${REMOTE_URL_OF_DOCS}" STREQUAL "${CURRENT_REMOTE_URL}")
        message("The remote URL has changed:")
        message("")
        message("REMOTE_URL_OF_DOCS = ${REMOTE_URL_OF_DOCS}")
        message("CURRENT_REMOTE_URL = ${CURRENT_REMOTE_URL}")
        message("")
        file(REMOVE_RECURSE "${PROJ_OUT_REPO_DIR}")
        file(MAKE_DIRECTORY "${PROJ_OUT_REPO_DIR}")
        execute_process(
            COMMAND ${Git_EXECUTABLE} clone
                    --depth=1
                    --single-branch
                    --recurse-submodules
                    --shallow-submodules
                    ${REMOTE_URL_OF_DOCS}
                    ${PROJ_OUT_REPO_DIR}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            ECHO_OUTPUT_VARIABLE
            ECHO_ERROR_VARIABLE
            COMMAND_ERROR_IS_FATAL ANY)
    else()
        message("The repository is already cloned in '${PROJ_OUT_REPO_DIR}/'.")
    endif()
endif()
message("")
restore_cmake_message_indent()


message(STATUS "Creating and switching to the local branch 'current' of the repository...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${Git_EXECUTABLE} checkout -B current
    WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    COMMAND_ERROR_IS_FATAL ANY)
message("")
restore_cmake_message_indent()


message(STATUS "Removing untracked files/directories of the repository...")
remove_cmake_message_indent()
message("")
execute_process(
    COMMAND ${Git_EXECUTABLE} clean -xfdf
    WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
    ECHO_OUTPUT_VARIABLE
    ECHO_ERROR_VARIABLE
    COMMAND_ERROR_IS_FATAL ANY)
if(EXISTS "${PROJ_OUT_REPO_DIR}/.gitmodules")
    message("")
    execute_process(
        COMMAND ${Git_EXECUTABLE} submodule foreach --recursive
                ${Git_EXECUTABLE} clean -xfdf
        WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
endif()
message("")
restore_cmake_message_indent()


if(VERSION_TYPE STREQUAL "branch")
    message(STATUS "Getting the latest commit of the branch '${BRANCH_NAME}' from the remote...")
    get_git_latest_commit_on_branch_name(
        IN_REPO_PATH        "${PROJ_OUT_REPO_DIR}"
        IN_SOURCE_TYPE      "remote"
        IN_BRANCH_NAME      "${BRANCH_NAME}"
        OUT_COMMIT_HASH     LATEST_COMMIT_HASH)
    remove_cmake_message_indent()
    message("")
    message("LATEST_COMMIT_HASH = ${LATEST_COMMIT_HASH}")
    message("")
    restore_cmake_message_indent()
    message(STATUS "Fetching the latest commit '${LATEST_COMMIT_HASH}' to the local branch '${BRANCH_NAME}'...")
    remove_cmake_message_indent()
    message("")
    execute_process(
        COMMAND ${Git_EXECUTABLE} fetch origin
                ${LATEST_COMMIT_HASH}:refs/heads/${BRANCH_NAME}
                --depth=1
                --verbose
                --force   # To sovle the following error message:
                # POST git-upload-pack (102 bytes)
                # POST git-upload-pack (gzip 2235 to 841 bytes)
                # From https://gitlab.kitware.com/cmake/cmake
                #  ! [rejected]            34146501ffe30f14d0ca5b999b3ec407d27450fb -> master  (non-fast-forward)
        WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
    message("")
    restore_cmake_message_indent()
elseif(VERSION_TYPE STREQUAL "tag")
    message(STATUS "Getting the latest tag of '${TAG_PATTERN}' from the remote...")
    get_git_latest_tag_on_tag_pattern(
        IN_REPO_PATH        "${PROJ_OUT_REPO_DIR}"
        IN_SOURCE_TYPE      "remote"
        IN_TAG_PATTERN      "${TAG_PATTERN}"
        IN_TAG_SUFFIX       "${TAG_SUFFIX}"
        OUT_TAG             LATEST_TAG)
    remove_cmake_message_indent()
    message("")
    message("LATEST_TAG = ${LATEST_TAG}")
    message("")
    restore_cmake_message_indent()
    message(STATUS "Fetching the latest tag '${LATEST_TAG}' to the local tag '${LATEST_TAG}'...")
    remove_cmake_message_indent()
    message("")
    execute_process(
        COMMAND ${Git_EXECUTABLE} fetch origin
                refs/tags/${LATEST_TAG}:refs/tags/${LATEST_TAG}
                --depth=1
                --verbose
        WORKING_DIRECTORY ${PROJ_OUT_REPO_DIR}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
    message("")
    restore_cmake_message_indent()
else()
    message(FATAL_ERROR "Invalid VERSION_TYPE value. (${VERSION_TYPE})")
endif()
