# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

cmake_minimum_required(VERSION 3.25)
get_filename_component(SCRIPT_NAME "${CMAKE_CURRENT_LIST_FILE}" NAME_WE)
set(CMAKE_MESSAGE_INDENT "[${VERSION}][${LANGUAGE}] ")
set(CMAKE_MESSAGE_INDENT_BACKUP "${CMAKE_MESSAGE_INDENT}")
message(STATUS "-------------------- ${SCRIPT_NAME} --------------------")


set(CMAKE_MODULE_PATH   "${PROJ_CMAKE_MODULES_DIR}")
find_package(Gettext    MODULE REQUIRED COMPONENTS Msgmerge)
find_package(Crowdin    MODULE REQUIRED)
include(JsonUtils)
include(LogUtils)


file(READ "${LANGUAGES_JSON_PATH}" LANGUAGES_JSON_CNT)
if(NOT LANGUAGE STREQUAL "all")
    set(LANGUAGE_LIST "${LANGUAGE}")
endif()
foreach(_LANGUAGE ${LANGUAGE_LIST})
    get_json_value_by_dot_notation(
        IN_JSON_OBJECT    "${LANGUAGES_JSON_CNT}"
        IN_DOT_NOTATION   ".${_LANGUAGE}.crowdin"
        OUT_JSON_VALUE    _LANGUAGE_CROWDIN)


    message(STATUS "Running 'crowdin download' command to download .po files for '${_LANGUAGE_CROWDIN}' language...")
    remove_cmake_message_indent()
    message("")
    execute_process(
        COMMAND ${Crowdin_EXECUTABLE} download
                --language ${_LANGUAGE_CROWDIN}
                --branch ${VERSION}
                --config ${TMS_CONFIG_FILE_PATH}
                --export-only-approved
                --no-progress
                --verbose
        WORKING_DIRECTORY ${PROJ_L10N_VERSION_DIR}
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        COMMAND_ERROR_IS_FATAL ANY)
    message("")
    restore_cmake_message_indent()


    message(STATUS "Running 'msgmerge' command to sync translations from .tmstmp to locale...")
    set(TMSTMP_PO_DIR   "${PROJ_L10N_VERSION_TMSTMP_DIR}/${_LANGUAGE}")
    set(LOCALE_PO_DIR   "${PROJ_L10N_VERSION_LOCALE_DIR}/${_LANGUAGE}")
    set(LOCALE_POT_DIR  "${PROJ_L10N_VERSION_LOCALE_DIR}/pot")
    remove_cmake_message_indent()
    message("")
    message("TMSTMP_PO_DIR  = ${TMSTMP_PO_DIR}")
    message("LOCALE_PO_DIR  = ${LOCALE_PO_DIR}")
    message("LOCALE_POT_DIR = ${LOCALE_POT_DIR}")
    message("")
    file(GLOB_RECURSE TMSTMP_PO_FILES "${TMSTMP_PO_DIR}/*.po")
    foreach(TMSTMP_PO_FILE ${TMSTMP_PO_FILES})
        string(REPLACE "${TMSTMP_PO_DIR}/" "" TMSTMP_PO_FILE_RELATIVE "${TMSTMP_PO_FILE}")
        string(REGEX REPLACE "\\.po$" ".pot" LOCALE_POT_FILE_RELATIVE "${TMSTMP_PO_FILE_RELATIVE}")
        set(LOCALE_PO_FILE          "${LOCALE_PO_DIR}/${TMSTMP_PO_FILE_RELATIVE}")
        set(LOCALE_POT_FILE         "${LOCALE_POT_DIR}/${LOCALE_POT_FILE_RELATIVE}")
        message("msgmerge:")
        message("  --lang           ${_LANGUAGE}")
        message("  --width          ${GETTEXT_WRAP_WIDTH}")
        message("  --compendium     ${TMSTMP_PO_FILE}")
        message("  --output-file    ${LOCALE_PO_FILE}")
        message("  [def.po]         ${LOCALE_POT_FILE}")
        message("  [ref.pot]        ${LOCALE_POT_FILE}")
        execute_process(
            COMMAND ${Gettext_MSGMERGE_EXECUTABLE}
                    --lang ${_LANGUAGE}
                    --width ${GETTEXT_WRAP_WIDTH}
                    --compendium ${TMSTMP_PO_FILE}
                    --output-file ${LOCALE_PO_FILE}
                    ${LOCALE_POT_FILE}  # [def.po]
                    ${LOCALE_POT_FILE}  # [ref.pot]
            RESULT_VARIABLE RES_VAR
            OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
        if(RES_VAR EQUAL 0)
        else()
            string(APPEND FAILURE_REASON
            "The command failed with fatal errors.\n\n"
            "    result:\n\n${RES_VAR}\n\n"
            "    stdout:\n\n${OUT_VAR}\n\n"
            "    stderr:\n\n${ERR_VAR}")
            message(FATAL_ERROR "${FAILURE_REASON}")
        endif()
    endforeach()
    unset(TMSTMP_PO_FILE)
    message("")
    restore_cmake_message_indent()
endforeach()
unset(_LANGUAGE)
