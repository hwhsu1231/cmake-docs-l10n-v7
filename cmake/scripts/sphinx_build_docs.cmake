# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE.txt for details.

cmake_minimum_required(VERSION 3.25)
get_filename_component(SCRIPT_NAME "${CMAKE_CURRENT_LIST_FILE}" NAME_WE)
set(CMAKE_MESSAGE_INDENT "[${VERSION}][${LANGUAGE}] ")
set(CMAKE_MESSAGE_INDENT_BACKUP "${CMAKE_MESSAGE_INDENT}")
message(STATUS "-------------------- ${SCRIPT_NAME} --------------------")


set(CMAKE_MODULE_PATH   "${PROJ_CMAKE_MODULES_DIR}")
set(Sphinx_ROOT_DIR     "${PROJ_VENV_DIR}")
find_package(Git        MODULE REQUIRED)
find_package(Gettext    MODULE REQUIRED COMPONENTS Msgcat Msgmerge)
find_package(Sphinx     MODULE REQUIRED COMPONENTS Build)
include(JsonUtils)
include(LogUtils)
include(GettextUtils)


message(STATUS "Removing directory '${PROJ_OUT_REPO_DOCS_LOCALE_DIR}/'...")
if(EXISTS "${PROJ_OUT_REPO_DOCS_LOCALE_DIR}")
    file(REMOVE_RECURSE "${PROJ_OUT_REPO_DOCS_LOCALE_DIR}")
    remove_cmake_message_indent()
    message("")
    message("Directory '${PROJ_OUT_REPO_DOCS_LOCALE_DIR}/' exists.")
    message("Removed '${PROJ_OUT_REPO_DOCS_LOCALE_DIR}/'.")
    message("")
    restore_cmake_message_indent()
else()
    remove_cmake_message_indent()
    message("")
    message("Directory '${PROJ_OUT_REPO_DOCS_LOCALE_DIR}/' does NOT exist.")
    message("No need to remove '${PROJ_OUT_REPO_DOCS_LOCALE_DIR}/'.")
    message("")
    restore_cmake_message_indent()
endif()


message(STATUS "Copying .po files to the local repository...")
if(NOT LANGUAGE STREQUAL "all")
    set(PO_SRC_DIR  "${PROJ_L10N_VERSION_LOCALE_DIR}/${LANGUAGE}")
    set(PO_DST_DIR  "${PROJ_OUT_REPO_DOCS_LOCALE_DIR}/${LANGUAGE}")
else()
    set(PO_SRC_DIR  "${PROJ_L10N_VERSION_LOCALE_DIR}")
    set(PO_DST_DIR  "${PROJ_OUT_REPO_DOCS_LOCALE_DIR}")
endif()
remove_cmake_message_indent()
message("")
message("From: ${PO_SRC_DIR}/")
message("To:   ${PO_DST_DIR}/")
message("")
copy_po_from_src_to_dst(
    IN_SRC_DIR  "${PO_SRC_DIR}"
    IN_DST_DIR  "${PO_DST_DIR}")
message("")
restore_cmake_message_indent()


if(NOT LANGUAGE STREQUAL "all")
    set(LANGUAGE_LIST "${LANGUAGE}")
endif()
foreach(_LANGUAGE ${LANGUAGE_LIST})
    message(STATUS "Running 'sphinx-build' command with '${SPHINX_BUILDER}' builder to build documentation for '${_LANGUAGE}' language...")
    set(ENV_LANG                "${SPHINX_CONSOLE_LOCALE}")
    set(ENV_KEY_VALUE_LIST      LANG=${ENV_LANG})
    remove_cmake_message_indent()
    message("")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E env ${ENV_KEY_VALUE_LIST}
                ${Sphinx_BUILD_EXECUTABLE}
                -b ${SPHINX_BUILDER}
                -D locale_dirs=${LOCALE_TO_SOURCE_DIR}            # Relative to <sourcedir>.
                -D language=${_LANGUAGE}
                -D gettext_compact=0
                -D gettext_additional_targets=${GETTEXT_ADDITIONAL_TARGETS}
                -A versionswitch=1
                -j ${SPHINX_JOB_NUMBER}
                ${SPHINX_VERBOSE_ARGS}
                -c ${PROJ_OUT_REPO_DOCS_CONFIG_DIR}               # <configdir>, where conf.py locates.
                ${PROJ_OUT_REPO_DOCS_SOURCE_DIR}                  # <sourcedir>, where index.rst locates.
                ${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/${VERSION}   # <outputdir>, where .html generates.
        ENCODING AUTO
        ECHO_OUTPUT_VARIABLE
        ECHO_ERROR_VARIABLE
        RESULT_VARIABLE RES_VAR
        OUTPUT_VARIABLE OUT_VAR OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  ERR_VAR ERROR_STRIP_TRAILING_WHITESPACE)
    if(RES_VAR EQUAL 0)
        if(ERR_VAR)
            string(APPEND WARNING_REASON
            "The command succeeded but had some warnings.\n\n"
            "    result:\n\n${RES_VAR}\n\n"
            "    stderr:\n\n${ERR_VAR}")
            message("${WARNING_REASON}")
        endif()
    else()
        string(APPEND FAILURE_REASON
        "The command failed with fatal errors.\n\n"
        "    result:\n\n${RES_VAR}\n\n"
        "    stderr:\n\n${ERR_VAR}")
        message(FATAL_ERROR "${FAILURE_REASON}")
    endif()
    message("")
    restore_cmake_message_indent()


    if(REMOVE_REDUNDANT)
        message(STATUS "Removing redundant files/directories...")
        file(REMOVE_RECURSE "${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/${VERSION}/.doctrees/")
        file(REMOVE         "${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/${VERSION}/.buildinfo")
        file(REMOVE         "${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/${VERSION}/objects.inv")
        remove_cmake_message_indent()
        message("")
        message("Removed '${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/${VERSION}/.doctrees/'.")
        message("Removed '${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/${VERSION}/.buildinfo'.")
        message("Removed '${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/${VERSION}/objects.inv'.")
        message("")
        restore_cmake_message_indent()
    endif()


    if(SPHINX_BUILDER MATCHES "^html$")
        message(STATUS "Coying 'version_switch.js' file to the html output directory...")
        set(PROTOCOLS "file:///" "https://")
        foreach(PROTOCOL ${PROTOCOLS})
            string(REGEX REPLACE "${PROTOCOL}" "" BASEURL ${BASEURL_HREF})
            if(NOT "${BASEURL}" STREQUAL "${BASEURL_HREF}")
                break()
            endif()
        endforeach()
        unset(PROTOCOL)
        set(LANGURL_HREF  "${BASEURL_HREF}/${_LANGUAGE}")
        set(LANGURL       "${BASEURL}/${_LANGUAGE}")
        set(LANGURL_RE    "${BASEURL}/${_LANGUAGE}")
        string(REPLACE "." "\\." LANGURL_RE "${LANGURL_RE}")
        string(REPLACE "/" "\\/" LANGURL_RE "${LANGURL_RE}")
        remove_cmake_message_indent()
        message("")
        message("From: ${PROJ_CMAKE_TEMPLATES_DIR}/version_switch.js.in")
        message("To:   ${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/version_switch.js")
        message("")
        message("BASEURL_HREF = ${BASEURL_HREF}")
        message("BASEURL      = ${BASEURL}")
        message("LANGURL_HREF = ${LANGURL_HREF}")
        message("LANGURL      = ${LANGURL}")
        message("LANGURL_RE   = ${LANGURL_RE}")
        message("")
        restore_cmake_message_indent()
        configure_file(
            "${PROJ_CMAKE_TEMPLATES_DIR}/version_switch.js.in"
            "${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/version_switch.js"
            @ONLY)
    endif()
endforeach()
unset(_LANGUAGE)


message(STATUS "The '${SPHINX_BUILDER}' documentation is built succesfully!")
remove_cmake_message_indent()
message("")
foreach(_LANGUAGE ${LANGUAGE_LIST})
    message("${_LANGUAGE} : ${PROJ_OUT_BUILDER_DIR}/${_LANGUAGE}/${VERSION}/index.html")
endforeach()
message("")
restore_cmake_message_indent()
