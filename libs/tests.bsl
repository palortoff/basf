#!/bin/bash

###
## @file
## @ingroup lib
## @brief Test functions
###

###
## @fn has_option()
## @brief The function returns true if and only if the option named in the first parameter
##        is contained in the remaining parameters in it's -short or --long format
##
## @param option_name The name of the wanted option.
## @param values The list in which to search.
## @retval 0 if and only if the wanted options is set
## @retval 1 otherwise
###
has_option(){
    local wanted_option=$1 wanted_short wanted_long=thisoptionwillprobablynotbeusedatall
    shift

    local longs=thisoptionwillprobablynotbeusedatall options
    make_option() {
        local name short long TEMP
        TEMP=`getopt --longoptions short:,long:,desc:,name:,hidden -- funcname "$@"`
        eval set -- "$TEMP"

        while true; do
            case "$1" in
                --name ) name=$2; shift 2 ;;
                --desc ) shift 2 ;;
                --long ) long=$2; longs="${longs},$2"; shift 2 ;;
                --short ) short=$2; options="${options}$2"; shift 2 ;;
                --hidden ) shift 1 ;;
                -- ) shift; break ;;
                * ) break ;;
            esac
        done

        if [ "${name}" == "${wanted_option}" ] ; then
            wanted_long=$long
            wanted_short=$short
        fi

    }

    if is_function describe_${action}_options; then
        describe_${action}_options

        local TEMP=`getopt -q --longoptions "${longs}" --options "${options}" -- $@`
        eval set -- "$TEMP"

        while true; do
            case "$1" in
                -${wanted_short} | --${wanted_long} ) return 0 ;;
                -- ) shift; break ;;
                * ) shift ;;
            esac
        done
    fi

    return 1
}

has_no_option() {
    x=`getopt -q -- "" funcname "$@"`
}

###
## @fn is_function()
## @brief `is_function` returns true if and only if its parameter exists and
##        is a function. This is mostly used internally, but could also be
##        useful elsewhere.
##
## @param var The test variable.
###
is_function() {
    declare -f -F "${1}" > /dev/null
}

###
## @fn is_number()
## @brief Returns true if and only if the parameter is a positive whole number.
## @param var The test variable.
###
is_number() {
    [[ -n ${1} ]] && [[ -z ${1//[[:digit:]]} ]]
}


# vi: set shiftwidth=4 tabstop=4 expandtab:
