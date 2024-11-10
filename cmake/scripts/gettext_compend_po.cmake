# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

cmake_minimum_required(VERSION 3.25)
get_filename_component(SCRIPT_NAME "${CMAKE_CURRENT_LIST_FILE}" NAME_WE)
set(CMAKE_MESSAGE_INDENT "[${VERSION}][${LANGUAGE}] ")
set(CMAKE_MESSAGE_INDENT_BACKUP "${CMAKE_MESSAGE_INDENT}")
message(STATUS "-------------------- ${SCRIPT_NAME} --------------------")


set(CMAKE_MODULE_PATH   "${PROJ_CMAKE_MODULES_DIR}")
find_package(Gettext    MODULE REQUIRED COMPONENTS Msgcat Msgmerge)
include(LogUtils)


if (VERSION_COMPENDIUM STREQUAL VERSION OR
    VERSION_COMPENDIUM STREQUAL "")
    message(STATUS "No need to merge translations from compendium.")
    return()
endif()


if(NOT LANGUAGE STREQUAL "all")
    set(LANGUAGE_LIST "${LANGUAGE}")
endif()
foreach(_LANGUAGE ${LANGUAGE_LIST})
    set(SRC_VERSION         "${VERSION_COMPENDIUM}")
    set(SRC_LOCALE_PO_DIR   "${PROJ_L10N_DIR}/${SRC_VERSION}/locale/${_LANGUAGE}")
    set(SRC_COMPEND_PO_FILE "${PROJ_L10N_DIR}/${SRC_VERSION}/.compend/${_LANGUAGE}.po")
    set(DST_VERSION         "${VERSION}")
    set(DST_LOCALE_PO_DIR   "${PROJ_L10N_DIR}/${DST_VERSION}/locale/${_LANGUAGE}")
    set(DST_LOCALE_POT_DIR  "${PROJ_L10N_DIR}/${DST_VERSION}/locale/pot")
    remove_cmake_message_indent()
    message("")
    message("SRC_VERSION            = ${SRC_VERSION}")
    message("SRC_LOCALE_PO_DIR      = ${SRC_LOCALE_PO_DIR}")
    message("SRC_COMPEND_PO_FILE    = ${SRC_COMPEND_PO_FILE}")
    message("DST_VERSION            = ${DST_VERSION}")
    message("DST_LOCALE_PO_DIR      = ${DST_LOCALE_PO_DIR}")
    message("DST_LOCALE_POT_DIR     = ${DST_LOCALE_POT_DIR}")
    message("")
    restore_cmake_message_indent()


    message(STATUS "Running 'msgcat' command to concatenate translations of '${VERSION_COMPENDIUM}' version for '${_LANGUAGE}' language...")
    file(GLOB_RECURSE SRC_LOCALE_PO_FILES "${SRC_LOCALE_PO_DIR}/*.po")
    get_filename_component(SRC_COMPENDIUM_PO_DIR "${SRC_COMPEND_PO_FILE}" DIRECTORY)
    file(MAKE_DIRECTORY "${SRC_COMPENDIUM_PO_DIR}")
    remove_cmake_message_indent()
    message("")
    message("msgcat:")
    message("  --output-file ${SRC_COMPEND_PO_FILE}")
    message("  --use-first")
    foreach(SRC_LOCALE_PO_FILE ${SRC_LOCALE_PO_FILES})
    message("  ${SRC_LOCALE_PO_FILE}")
    endforeach()
    execute_process(
        COMMAND ${Gettext_MSGCAT_EXECUTABLE}
                --output-file ${SRC_COMPEND_PO_FILE}
                --use-first
                ${SRC_LOCALE_PO_FILES}
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
    message("")
    restore_cmake_message_indent()


    message(STATUS "Running 'msgmerge' command to merge translations from '${VERSION_COMPENDIUM}' version...")
    remove_cmake_message_indent()
    message("")
    file(GLOB_RECURSE DST_LOCALE_PO_FILES "${DST_LOCALE_PO_DIR}/*.po")
    foreach(DST_LOCALE_PO_FILE ${DST_LOCALE_PO_FILES})
        string(REPLACE "${DST_LOCALE_PO_DIR}/" "" DST_PO_FILE_RELATIVE "${DST_LOCALE_PO_FILE}")
        set(DST_LOCALE_PO_FILE "${DST_LOCALE_PO_DIR}/${DST_PO_FILE_RELATIVE}")
        string(REGEX REPLACE "\\.po$" ".pot" DST_POT_FILE_RELATIVE "${DST_PO_FILE_RELATIVE}")
        set(DST_LOCALE_POT_FILE "${DST_LOCALE_POT_DIR}/${DST_POT_FILE_RELATIVE}")
        message("msgmerge:")
        message("  --lang         ${_LANGUAGE}")
        message("  --width        ${GETTEXT_WRAP_WIDTH}")
        message("  --compendium   ${SRC_COMPEND_PO_FILE}")
        message("  --output-file  ${DST_LOCALE_PO_FILE}")
        message("  [def.po]       ${DST_LOCALE_POT_FILE}")
        message("  [ref.pot]      ${DST_LOCALE_POT_FILE}")
        execute_process(
            COMMAND ${Gettext_MSGMERGE_EXECUTABLE}
                    --lang ${_LANGUAGE}
                    --width ${GETTEXT_WRAP_WIDTH}
                    --compendium ${SRC_COMPEND_PO_FILE}
                    --output-file ${DST_LOCALE_PO_FILE}
                    ${DST_LOCALE_POT_FILE}  # [def.po]
                    ${DST_LOCALE_POT_FILE}  # [ref.pot]
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
    unset(DST_LOCALE_PO_FILE)
    message("")
    restore_cmake_message_indent()
endforeach()
unset(_LANGUAGE)
