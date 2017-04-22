#!/bin/bash

###
## @file
## @ingroup lib
## @brief The implicit base 'class' for all modules.
##
## This file is the base (as in 'abstract base class' if you still think OOP)
## for all modules.
##
## Technical speaking: this file is sourced (loaded into the current shell context)
## and then the requested module. Therefore the module can override/redeclare
## everything defined in this file, but this file provides useful defaults.
##
## @note The comments in this file are not meant to explain how to write a
##       module. A documented example module can be found in the
##       skeleton.${BASF_LIBRARY_EXTENSION} file.
###


## @var DESCRIPTION
## @brief The description of this module
declare DESCRIPTION=""

## @var DEFAULT_ACTION
## @brief The default action to execute if none is given
declare DEFAULT_ACTION="help"

## @var VERSION
## @brief The version of this module
declare VERSION=""

###
## @protected
## @fn describe_usage()
## @brief Default description for the usage action
###
describe_usage() {
    echo "Display usage information"
}

###
## @protected
## @fn do_usage()
## @brief Default usage action to display a brief usage help
###
do_usage() {
    echo "Usage: ${BASF_COMMAND} <action> [<options>]"
}

###
## @protected
## @fn describe_version()
## @brief Default description for the version action
###
describe_version() {
    echo "Display version information"
}

###
## @protected
## @fn do_version()
## @brief Default version action to display module related version informations
###
do_version() {
    # display also module version information if this action was invoked on a module
    [[ -n ${BASF_MODULE_NAME} && -n ${VERSION} ]] && echo "${BASF_MODULE_NAME}.${BASF_MODULE_EXTENSION} ${VERSION}"
    echo "${BASF_PROGRAM_NAME} ${BASF_PROGRAM_VERSION}"
    echo "BASF ${BASF_VERSION}"
}

###
## @protected
## @fn describe_help()
## @brief Default description for the help action
###
describe_help() {
    echo "Display help text"
}

###
## @protected
## @fn make_option()
## @brief print a colon separated option help string
## @example `make_option --name "attach"   --short "a" --long "attach"   --desc "start in current console"`
###
make_option() {
    TEMP=`getopt --long short:,long:,desc:,name:,hidden -- funcname "$@"`
    eval set -- "$TEMP"

    local long short desc hidden

    while true; do
        case "$1" in
            --name ) shift 2 ;;
            --long ) long=$2; shift 2 ;;
            --short ) short=$2; shift 2 ;;
            --desc ) desc=$2; shift 2 ;;
            --hidden ) return 0;;
            -- ) shift; break ;;
            * ) break ;;
        esac
    done
    if [ ! -z ${short} ]; then
        short="-${short}"
    else
        short="  "
    fi
    if [ ! -z ${long} ]; then long="--${long}"; fi
    echo "${short} ${long} : ${desc}"
}

###
## @protected
## @fn do_help()
## @brief Default help action to display module related help
###
do_help() {
    [[ "${DESCRIPTION}" ]] && echo "${DESCRIPTION}"

    echo "Usage: ${BASF_COMMAND} <action> <options>"
    echo

    write_list_start "Standard actions:"
    for action in help usage version; do
        local desc=""
        is_function "describe_${action}" && desc=$(describe_${action})
        write_kv_list_entry "${action}" "${desc:-(no description)}"
    done

    echo
    write_list_start "Extra actions:"

    # for newbies:
    #  set is a command every POSIX compatible shell must implement.
    #  POSIX also requires, that if set is called without arguments,
    #  set shall print all shell variables as key/value pairs.
    #  A look says more than thousand words -> open your shell and have a look.
    local actionList=()
    for action in $(set | sed -n -e '/^do_\S\+ ()\s*$/s/^do_\(\S\+\).*/\1/p' | sort); do
        if [ "${action}" == "list" ] ; then
            actionList=( "$action" ${actionList[@]} )
        else
            actionList+=( "$action" )
        fi
    done

    # The for loop interates over all shell variables which are functions
    # _and_ starts with the prefix "do_". In the body of the loop the $action
    # variable contains the name of the function without the do_ prefix
    # or " ()" suffix.
    for action in "${actionList[@]}"; do
        case "${action}" in
            help|usage|version|action)
                continue
                ;;
            ?*)
                is_function "hide_${action}" && hide_${action} && continue

                # call corresponding functions if available to read the descriptions
                local desc=""
                is_function "describe_${action}" && desc=$(describe_${action})

                local name="${action}"
                if is_function "name_${action}" ; then
                    name="$(name_${action})"
                    desc="${desc:- }"
                fi

                local text="${name}"
                if is_function "describe_${action}_parameters"; then
                    text+=" $(describe_${action}_parameters)"
                fi

                # display entry
                write_kv_list_entry "${text}" "${desc:-(no description)}"

                # print optional options
                if is_function "describe_${action}_options"; then
                    local line
                    local options=$(describe_${action}_options)
                    local ifs_save=${IFS} IFS=$'\n'
                    for line in ${options}; do
                        write_kv_list_entry -p \
                            "  ${line%%*( ):*}" \
                            "  ${line##+([^:]):*( )}"
                    done
                    echo
                    IFS=${ifs_save}
                fi
                ;;
        esac
    done

    true
}


# vi: set shiftwidth=4 tabstop=4 expandtab: