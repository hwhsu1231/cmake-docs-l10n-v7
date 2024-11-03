# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

cmake_minimum_required(VERSION 3.25)
get_filename_component(SCRIPT_NAME "${CMAKE_CURRENT_LIST_FILE}" NAME_WE)
set(CMAKE_MESSAGE_INDENT "[${VERSION}][${LANGUAGE}] ")
set(CMAKE_MESSAGE_INDENT_BACKUP "${CMAKE_MESSAGE_INDENT}")
message(STATUS "-------------------- ${SCRIPT_NAME} --------------------")


set(CMAKE_MODULE_PATH   "${PROJ_CMAKE_MODULES_DIR}")
find_package(Git        MODULE REQUIRED)
find_package(Gettext    MODULE REQUIRED COMPONENTS Msgcat Msgmerge)
include(JsonUtils)
include(LogUtils)


file(READ "${REFERENCES_JSON_PATH}" REFERENCES_JSON_CNT)
if(NOT LANGUAGE STREQUAL "all")
    set(LANGUAGE_LIST "${LANGUAGE}")
endif()
foreach(_LANGUAGE ${LANGUAGE_LIST})
    message(STATUS "Determining whether it is required to update .po files...")
    get_reference_of_pot_and_po_from_json(
        IN_JSON_CNT                     "${REFERENCES_JSON_CNT}"
        IN_VERSION_TYPE                 "${VERSION_TYPE}"
        OUT_POT_OBJECT                  CURRENT_POT_OBJECT
        OUT_POT_REFERENCE               CURRENT_POT_REFERENCE
        OUT_PO_OBJECT                   CURRENT_PO_OBJECT
        OUT_PO_REFERENCE                CURRENT_PO_REFERENCE)
    if(MODE_OF_UPDATE STREQUAL "COMPARE")
        if(NOT CURRENT_POT_REFERENCE STREQUAL CURRENT_PO_REFERENCE)
            set(UPDATE_PO_REQUIRED      ON)
        else()
            set(UPDATE_PO_REQUIRED      OFF)
        endif()
    elseif(MODE_OF_UPDATE STREQUAL "ALWAYS")
        set(UPDATE_PO_REQUIRED          ON)
    elseif(MODE_OF_UPDATE STREQUAL "NEVER")
        if(NOT CURRENT_PO_REFERENCE)
            set(UPDATE_PO_REQUIRED      ON)
        else()
            set(UPDATE_PO_REQUIRED      OFF)
        endif()
    else()
        message(FATAL_ERROR "Invalid MODE_OF_UPDATE value. (${MODE_OF_UPDATE})")
    endif()
    remove_cmake_message_indent()
    message("")
    message("CURRENT_POT_OBJECT     = ${CURRENT_POT_OBJECT}")
    message("CURRENT_PO_OBJECT      = ${CURRENT_PO_OBJECT}")
    message("CURRENT_POT_REFERENCE  = ${CURRENT_POT_REFERENCE}")
    message("CURRENT_PO_REFERENCE   = ${CURRENT_PO_REFERENCE}")
    message("MODE_OF_UPDATE         = ${MODE_OF_UPDATE}")
    message("UPDATE_PO_REQUIRED     = ${UPDATE_PO_REQUIRED}")
    message("")
    restore_cmake_message_indent()


    if(NOT UPDATE_PO_REQUIRED)
        message(STATUS "No need to update .po files for '${_LANGUAGE}' language.")
        continue()
    else()
        message(STATUS "Prepare to update .po files for '${_LANGUAGE}' language.")
    endif()


    message(STATUS "Running 'msgmerge/msgcat' command to update .po files for '${_LANGUAGE}' language...")
    set(POT_DIR "${PROJ_L10N_VERSION_LOCALE_DIR}/pot")
    set(PO_DIR  "${PROJ_L10N_VERSION_LOCALE_DIR}/${_LANGUAGE}")
    remove_cmake_message_indent()
    message("")
    message("From: ${POT_DIR}/")
    message("To:   ${PO_DIR}/")
    message("")
    file(GLOB_RECURSE POT_FILES "${POT_DIR}/*.pot")
    foreach(POT_FILE ${POT_FILES})
        string(REPLACE "${POT_DIR}/" "" POT_FILE_RELATIVE "${POT_FILE}")
        string(REGEX REPLACE "\\.pot$" ".po" PO_FILE_RELATIVE "${POT_FILE_RELATIVE}")
        set(PO_FILE "${PO_DIR}/${PO_FILE_RELATIVE}")
        get_filename_component(PO_FILE_DIR "${PO_FILE}" DIRECTORY)
        file(MAKE_DIRECTORY "${PO_FILE_DIR}")
        if(EXISTS "${PO_FILE}")
            #
            # If the ${PO_FILE} exists, then merge it using msgmerge.
            #
            message("msgmerge:")
            message("  --lang       ${_LANGUAGE}")
            message("  --width      ${GETTEXT_WRAP_WIDTH}")
            message("  --backup     off")
            message("  --update")
            message("  --force-po")
            message("  --no-fuzzy-matching")
            message("  [def.po]     ${PO_FILE}")
            message("  [ref.pot]    ${POT_FILE}")
            execute_process(
                COMMAND ${Gettext_MSGMERGE_EXECUTABLE}
                        --lang=${_LANGUAGE}
                        --width=${GETTEXT_WRAP_WIDTH}
                        --backup=off
                        --update
                        --force-po
                        --no-fuzzy-matching
                        ${PO_FILE}      # [def.po]
                        ${POT_FILE}     # [ref.pot]
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
        else()
            #
            # If the ${PO_FILE} doesn't exist, then create it using msgcat.
            #
            message("msgcat:")
            message("  --lang         ${_LANGUAGE}")
            message("  --width        ${GETTEXT_WRAP_WIDTH}")
            message("  --output-file  ${PO_FILE}")
            message("  [inputfile]    ${POT_FILE}")
            execute_process(
                COMMAND ${Gettext_MSGCAT_EXECUTABLE}
                        --lang=${_LANGUAGE}
                        --width=${GETTEXT_WRAP_WIDTH}
                        --output-file=${PO_FILE}
                        ${POT_FILE}
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
        endif()
    endforeach()
    unset(POT_FILE)
    message("")
    restore_cmake_message_indent()


    set_json_value_by_dot_notation(
        IN_JSON_OBJECT      "${REFERENCES_JSON_CNT}"
        IN_DOT_NOTATION     ".po.${_LANGUAGE}"
        IN_JSON_VALUE       "${CURRENT_POT_OBJECT}"
        OUT_JSON_OBJECT     REFERENCES_JSON_CNT)
endforeach()
unset(_LANGUAGE)


file(WRITE "${REFERENCES_JSON_PATH}" "${REFERENCES_JSON_CNT}")
