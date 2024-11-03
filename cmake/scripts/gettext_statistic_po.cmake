# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

cmake_minimum_required(VERSION 3.25)
get_filename_component(SCRIPT_NAME "${CMAKE_CURRENT_LIST_FILE}" NAME_WE)
set(CMAKE_MESSAGE_INDENT "[${VERSION}][${LANGUAGE}] ")
set(CMAKE_MESSAGE_INDENT_BACKUP "${CMAKE_MESSAGE_INDENT}")
message(STATUS "-------------------- ${SCRIPT_NAME} --------------------")


set(CMAKE_MODULE_PATH   "${PROJ_CMAKE_MODULES_DIR}")
find_package(Gettext    MODULE REQUIRED COMPONENTS Msgattrib)
include(JsonUtils)
include(LogUtils)


set(PADDING_LENGTH 3)
set(STATISTIC_TXT_CNT "")
foreach(_LANGUAGE ${LANGUAGE_LIST})
    message(STATUS "Counting the percentage for '${_LANGUAGE}' language...")
    #
    # Initialize the statistical infomation.
    #
    set(NUM_OF_PO_COMPLETED 0)      # Number     of completed   po    files
    set(NUM_OF_PO_PROGRESSING 0)    # Number     of progressing po    files
    set(NUM_OF_PO_UNSTARTED 0)      # Number     of unstarted   po    files
    set(NUM_OF_PO_TOTAL 0)          # Number     of total       po    files
    set(PCT_OF_PO_COMPLETED 0)      # Percentage of completed   po    files
    set(NUM_OF_MSGID_TRANSLATED 0)  # Number     of translated  msgid entries
    set(NUM_OF_MSGID_FUZZY 0)       # Number     of fuzzy       msgid entries
    set(NUM_OF_MSGID_TOTAL 0)       # Number     of total       msgid entries
    set(PCT_OF_MSGID_TRANSLATED 0)  # Percentage of translated  msgid entries

    file(GLOB_RECURSE PO_FILES "${PROJ_L10N_VERSION_LOCALE_DIR}/${_LANGUAGE}/*.po")
    if(NOT PO_FILES)
        message(FATAL_ERROR "PO_FILES is empty!")
    endif()

    remove_cmake_message_indent()
    message("")
    foreach(PO_FILE ${PO_FILES})
        #
        # Calculate the total msgid entries.
        #
        execute_process(
            COMMAND ${Gettext_MSGATTRIB_EXECUTABLE} --no-fuzzy --no-obsolete ${PO_FILE}
            RESULT_VARIABLE TOTAL_MSGID_RES
            OUTPUT_VARIABLE TOTAL_MSGID_OUT OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  TOTAL_MSGID_ERR ERROR_STRIP_TRAILING_WHITESPACE)
        if(TOTAL_MSGID_RES EQUAL 0)
            if(TOTAL_MSGID_OUT)
                string(REGEX MATCHALL "msgid" TOTAL_MSGID_MATCHES "${TOTAL_MSGID_OUT}")
                list(LENGTH TOTAL_MSGID_MATCHES TOTAL_MSGID_COUNT)
                math(EXPR TOTAL_MSGID_COUNT "${TOTAL_MSGID_COUNT} - 1") # Subtract 1 for the header msgid
                math(EXPR NUM_OF_MSGID_TOTAL "${NUM_OF_MSGID_TOTAL} + ${TOTAL_MSGID_COUNT}")
            else()
                set(TOTAL_MSGID_COUNT 0)
            endif()
        else()
            string(APPEND FAILURE_REASON
            "The command failed with fatal errors.\n\n"
            "    result:\n\n${TOTAL_MSGID_RES}\n\n"
            "    stdout:\n\n${TOTAL_MSGID_OUT}\n\n"
            "    stderr:\n\n${TOTAL_MSGID_ERR}")
            message(FATAL_ERROR "${FAILURE_REASON}")
        endif()
        #
        # Calculate the "translated" msgid entries
        #
        execute_process(
            COMMAND ${Gettext_MSGATTRIB_EXECUTABLE} --translated ${PO_FILE}
            RESULT_VARIABLE TRANSLATED_MSGID_RES
            OUTPUT_VARIABLE TRANSLATED_MSGID_OUT OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  TRANSLATED_MSGID_ERR ERROR_STRIP_TRAILING_WHITESPACE)
        if(TRANSLATED_MSGID_RES EQUAL 0)
            if(TRANSLATED_MSGID_OUT)
                string(REGEX MATCHALL "msgid" TRANSLATED_MSGID_MATCHES "${TRANSLATED_MSGID_OUT}")
                list(LENGTH TRANSLATED_MSGID_MATCHES TRANSLATED_MSGID_COUNT)
                math(EXPR TRANSLATED_MSGID_COUNT "${TRANSLATED_MSGID_COUNT} - 1") # Subtract 1 for the header msgid
                math(EXPR NUM_OF_MSGID_TRANSLATED "${NUM_OF_MSGID_TRANSLATED} + ${TRANSLATED_MSGID_COUNT}")
            else()
                set(TRANSLATED_MSGID_COUNT 0)
            endif()
        else()
            string(APPEND FAILURE_REASON
            "The command failed with fatal errors.\n\n"
            "    result:\n\n${TRANSLATED_MSGID_RES}\n\n"
            "    stdout:\n\n${TRANSLATED_MSGID_OUT}\n\n"
            "    stderr:\n\n${TRANSLATED_MSGID_ERR}")
            message(FATAL_ERROR "${FAILURE_REASON}")
        endif()
        #
        # Calculate the "fuzzy" msgid entries.
        #
        execute_process(
            COMMAND ${Gettext_MSGATTRIB_EXECUTABLE} --only-fuzzy --no-obsolete ${PO_FILE}
            RESULT_VARIABLE FUZZY_MSGID_RES
            OUTPUT_VARIABLE FUZZY_MSGID_OUT OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_VARIABLE  FUZZY_MSGID_ERR ERROR_STRIP_TRAILING_WHITESPACE)
        if(FUZZY_MSGID_RES EQUAL 0)
            if(FUZZY_MSGID_OUT)
                string(REGEX MATCHALL "msgid" FUZZY_MSGID_MATCHES ${FUZZY_MSGID_OUT})
                list(LENGTH FUZZY_MSGID_MATCHES FUZZY_MSGID_COUNT)
                math(EXPR FUZZY_MSGID_COUNT "${FUZZY_MSGID_COUNT} - 1") # Subtract 1 for the header msgid
                math(EXPR NUM_OF_MSGID_FUZZY "${NUM_OF_MSGID_FUZZY} + ${FUZZY_MSGID_COUNT}")
                return()
            else()
                set(FUZZY_MSGID_COUNT 0)
            endif()
        else()
            string(APPEND FAILURE_REASON
            "The command failed with fatal errors.\n\n"
            "    result:\n\n${FUZZY_MSGID_RES}\n\n"
            "    stdout:\n\n${FUZZY_MSGID_OUT}\n\n"
            "    stderr:\n\n${FUZZY_MSGID_ERR}")
            message(FATAL_ERROR "${FAILURE_REASON}")
        endif()

        if(NOT TOTAL_MSGID_RES AND NOT TRANSLATED_MSGID_RES)
            math(EXPR TRANSLATED_MSGID_PCT "100 * ${TRANSLATED_MSGID_COUNT} / ${TOTAL_MSGID_COUNT}")
            #
            # Prepend leading whitespaces to the 'PERCENTAGE_STR' until its length is ${PADDING_LENGTH}
            #
            set(PERCENTAGE_STR "${TRANSLATED_MSGID_PCT}")
            string(LENGTH "${PERCENTAGE_STR}" PERCENTAGE_LEN)
            while("${PERCENTAGE_LEN}" LESS ${PADDING_LENGTH})
                string(PREPEND PERCENTAGE_STR " ")
                string(LENGTH "${PERCENTAGE_STR}" PERCENTAGE_LEN)
            endwhile()
            #
            # Prepend leading whitespaces to the 'TRANSLATED_MSGID_STR' until its length is ${PADDING_LENGTH}
            #
            set(TRANSLATED_MSGID_STR "${TRANSLATED_MSGID_COUNT}")
            string(LENGTH "${TRANSLATED_MSGID_STR}" TRANSLATED_MSGID_LEN)
            while("${TRANSLATED_MSGID_LEN}" LESS ${PADDING_LENGTH})
                string(PREPEND TRANSLATED_MSGID_STR " ")
                string(LENGTH "${TRANSLATED_MSGID_STR}" TRANSLATED_MSGID_LEN)
            endwhile()
            #
            # Prepend leading whitespaces to the 'TOTAL_MSGID_STR' until its length is ${PADDING_LENGTH}
            #
            set(TOTAL_MSGID_STR "${TOTAL_MSGID_COUNT}")
            string(LENGTH "${TOTAL_MSGID_STR}" TOTAL_MSGID_LEN)
            while("${TOTAL_MSGID_LEN}" LESS ${PADDING_LENGTH})
                string(PREPEND TOTAL_MSGID_STR " ")
                string(LENGTH "${TOTAL_MSGID_STR}" TOTAL_MSGID_LEN)
            endwhile()
            #
            # Example out:
            # - [  0%][  0/ 99] path/to/po/file
            # - [ 30%][ 33/ 99] path/to/po/file
            # - [100%][ 99/ 99] path/to/po/file
            #
            message("[${PERCENTAGE_STR}%][${TRANSLATED_MSGID_STR}/${TOTAL_MSGID_STR}] ${PO_FILE}")
            #
            # Increment counters
            #
            if(TRANSLATED_MSGID_PCT EQUAL 100)
                math(EXPR NUM_OF_PO_COMPLETED "${NUM_OF_PO_COMPLETED} + 1")
            elseif(TRANSLATED_MSGID_PCT EQUAL 0)
                math(EXPR NUM_OF_PO_UNSTARTED "${NUM_OF_PO_UNSTARTED} + 1")
            else()
                math(EXPR NUM_OF_PO_PROGRESSING "${NUM_OF_PO_PROGRESSING} + 1")
            endif()
            math(EXPR NUM_OF_PO_TOTAL "${NUM_OF_PO_TOTAL} + 1")
        else()
            message(WARNING "Failed to get msgid counts for ${PO_FILE}.")
        endif()
    endforeach()
    unset(PO_FILE)

    math(EXPR NUM_OF_MSGID_UNTRANSLATED "${NUM_OF_MSGID_TOTAL} - ${NUM_OF_MSGID_TRANSLATED}")
    math(EXPR PCT_OF_PO_COMPLETED "(${NUM_OF_PO_COMPLETED} * 100) / ${NUM_OF_PO_TOTAL}")
    math(EXPR PCT_OF_MSGID_TRANSLATED "(${NUM_OF_MSGID_TRANSLATED} * 100) / ${NUM_OF_MSGID_TOTAL}")

    #
    # Print counts
    #

    message("")
    set(LOG_MESSAGES "[${_LANGUAGE}]\n")
    set(LOG_MESSAGES "${LOG_MESSAGES}Number     of completed   po    files   : ${NUM_OF_PO_COMPLETED}\n")
    set(LOG_MESSAGES "${LOG_MESSAGES}Number     of progressing po    files   : ${NUM_OF_PO_PROGRESSING}\n")
    set(LOG_MESSAGES "${LOG_MESSAGES}Number     of unstarted   po    files   : ${NUM_OF_PO_UNSTARTED}\n")
    set(LOG_MESSAGES "${LOG_MESSAGES}Number     of total       po    files   : ${NUM_OF_PO_TOTAL}\n")
    set(LOG_MESSAGES "${LOG_MESSAGES}Percentage of completed   po    files   : ${PCT_OF_PO_COMPLETED}%\n")
    set(LOG_MESSAGES "${LOG_MESSAGES}Number     of translated  msgid entries : ${NUM_OF_MSGID_TRANSLATED}\n")
    set(LOG_MESSAGES "${LOG_MESSAGES}Number     of fuzzy       msgid entries : ${NUM_OF_MSGID_FUZZY}\n")
    set(LOG_MESSAGES "${LOG_MESSAGES}Number     of total       msgid entries : ${NUM_OF_MSGID_TOTAL}\n")
    set(LOG_MESSAGES "${LOG_MESSAGES}Percentage of translated  msgid entries : ${PCT_OF_MSGID_TRANSLATED}%")
    message("${LOG_MESSAGES}")
    message("")
    restore_cmake_message_indent()

    set(STATISTIC_TXT_CNT "${STATISTIC_TXT_CNT}${LOG_MESSAGES}\n")
endforeach()
unset(_LANGUAGE)


file(WRITE "${STATISTIC_TXT_PATH}" "${STATISTIC_TXT_CNT}")
