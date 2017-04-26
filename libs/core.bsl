#!/bin/bash

###
## @file
## @ingroup lib
## @brief Widely used core functions.
###


###
## @fn killme()
## @brief Force exit with error code 249
###
killme() {
    # Evil, but effective.
    # kill would print a "Terminated" message which can't be redirected.
    # kill -PIPE does the same without any message.
    kill -PIPE ${BASF_KILL_TARGET}

    # notify the trap
    exit 249
}


###
## @fn die()
## @brief This function is used to exit with a fatal error.
##
## This function should be invoked as `die "Message to display"` or
## `die -q "Message to display"`.
##
## If the `-q` (quiet) option is not provided, a stacktrace will be displayed.
## The latter should only happen under abnormal conditions, not because
## of user input errors.
##
## @param message string to display, default is "(no message)"
## @param -q Optional, if specified the default stacktrace is not generiated
##
###
die() {
    # Restore stderr
    [[ -n ${BASF_STDERR} ]] && exec 2>&${BASF_STDERR}

    # do we have a working write_error_msg?
    local e
    if is_function "write_error_msg"; then
        e="write_error_msg"
    else
        e="echo"
    fi

    # quiet?
    local s="yes"
    if [[ $1 == "-q" ]]; then
        s=""
        shift
    fi

    $e "${@:-(no message)}" >&2

    local funcname=""
    local sourcefile=""
    local lineno=""
    if [[ -n ${s} ]]; then
        echo "Call stack:" >&2
        local n
        for (( n = 1; n < ${#FUNCNAME[@]}; ++n )); do
            funcname=${FUNCNAME[n]}
            sourcefile=$(basename ${BASH_SOURCE[n]})
            lineno=${BASH_LINENO[n-1]}
            echo "    * ${funcname} (${sourcefile}:${lineno})" >&2
        done
    fi

    killme
}


die_popd() {
    popd &>/dev/null
    die $@
}

###
## @private
## @fn find_module()
## @brief Find a module and print it's filename, else `die`.
##
## @param moduleName    The module name
## @see die()
###
find_module() {
    local modname=$1
    local mod=$( find_optional_module "${modname}" )
    if [ -n "$mod" ] ; then
        echo "$mod"
        return
    fi

    die -q "Can't locate module '${modname}'"
}

###
## @private
## @fn find_optional_module()
## @brief Find a module and print it's filename, otherwise print nothing
##
## @param moduleName    The module name
## @see die()
###
find_optional_module() {
    local modname=$1
    local modpath

    for modpath in "${BASF_MODULES_PATH[@]}"; do
        if [[ -f "${modpath}/${modname}.${BASF_MODULE_EXTENSION}" ]]; then
            echo "${modpath}/${modname}.${BASF_MODULE_EXTENSION}"
            return
        fi
        if [ ! -z "${BASF_CUSTOM_MODULE_EXTENSION}" ]; then
            if [[ -f "${modpath}/${modname}.${BASF_CUSTOM_MODULE_EXTENSION}" ]]; then
                echo "${modpath}/${modname}.${BASF_CUSTOM_MODULE_EXTENSION}"
                return
            fi
        fi
    done
}
###
## @fn check_do()
## @brief Check that the function @p function exists and
## call it with @p args, else `die`.
##
## @param function      The function to invoke
## @param args          List of function arguments
## @see die()
##
###
check_do() {
    local function=$1
    shift

    if is_function "${function}" ; then
        ${function} "$@"
    else
        die "No such function '${function}'"
    fi
}

get_module(){
    parsedOptions=`getopt -q -- "" "$@"`
    eval set -- "$parsedOptions"
    shift

    echo "${1##--}"
}

get_action(){
    parsedOptions=`getopt -q -- "" "$@"`
    eval set -- "$parsedOptions"
    shift; shift

    local action=""
    if [ ! ${1:0:1} == "-" ]; then  # second argument unless starting with -- prefix
        action="${1}"
    fi
    echo "${action}"
}

# FIXME: change function name.
#       the prefix "do_" makes this actually an action for any module, but calling it results in an error

###
## @private
## @fn do_action()
## @brief Load and do 'module' with the specified args
##
## @param module      The module to invoke
## @param action   Optional action to invoke
## @param args        List of module arguments
##
## @see check_do()
## @see die()
##
###
do_action() {
    local module=`get_module $@`
    local action=`get_action $@`

    [[ ${1} == ${module} ]] && shift
    [[ ${1} == ${action} ]] && shift

    # the length of the string module is nonzero - otherwise die
    [[ -n ${module} ]] || die "Usage: do_action <module> <args>"

    # The module might find this information useful
    BASF_MODULE_NAME="${module}"
    BASF_COMMAND="${BASF_BINARY_NAME} ${BASF_MODULE_NAME}"

    # load the module file
    local BASF_MODULE_FILE=$( find_optional_module "${module}" )

    (
        # source the 'abstract base class' and then the 'concret implementation'.
        local basf_default=$( find_lib default )
        [[ "$basf_default" ]]              || die "Can't locate default lib"
        source "$basf_default" 2>/dev/null || die "Couldn't source '$basf_default'"
        source "${BASF_MODULE_FILE}" 2>/dev/null  || die "Couldn't source ${BASF_MODULE_FILE}" # FIXME: does not print the module name if module is missing

# TODO: instead of "could not source", it should read "module not found, as message, not dying..."

        # if $action is empty, then
        #   - call the __module function if exists
        #   - else call the DEFAULT_ACTION if it is not empty
        #   - else call the usage module
        # else if a matching function exists (do_$action):
        #   - then call this function
        # else if a catch all function exists
        #   - then call the __action function
        # else
        #   - die
        #

        if [[ -z ${action} ]]; then
            if is_function "__module" ; then
                check_do "__module" "$@"
            else
                check_do "do_${DEFAULT_ACTION:-usage}" "$@"
            fi
        elif is_function "do_${action}"; then
            check_do "do_${action}" "$@"
        elif is_function "__call" ; then
            check_do "__call" ${action} "$@"
        elif is_function "__action" ; then
            check_do "__action" ${action} "$@"
        else
            die -q "Action ${action} unknown"
        fi
    )
}


###
## @fn inherit()
## @brief sources one or more basf libraries by name
##
## @param libraries   The library or libraries to load
##
###
inherit() {
    # for without 'for x' equals 'for x in $@', e.g. for each parameter specified
    local x lib
    for x; do
        lib=$( find_lib "${x}" )
        [[ -e ${lib} ]] || die "Can't locate library ${x}"
        source "${lib}" || die "Couldn't source library ${x}"
    done
}


###
##
###
invoke() {
    local module="$1"
    local action="$2"
    shift; shift

    $BASF_BINARY_NAME $module $action $@
}

###
## @fn human_timestamp_diff()
## @brief Prints the difference between the first and second timestamp
##        in a human-friendly string eg "32 minutes ago"
##
## The second parameter is optional.
## If not specified, it is set to the current time.
##
## @param old_timestamp    The older timestamp to compare
## @param newer_timestamp  Optional newer timestamp. If not specified, it is set to the current time.
###
human_timestamp_diff() {
    local ts="$1"
    local now="$2"

    [[ -n "$ts" ]]  || die
    is_number "$ts" || die

    [[ -n "$now" ]]  || now=`date +%s`
    is_number "$now" || die

    local diff=$(( ( now - ts ) / 60 ))

    #echo "$ts | $now | $diff";  exit 0

    if (( $diff >= 180 )); then
        if (( $diff > 4320 )); then
            echo "$(( diff / 1440 )) days ago"
        else
            echo "$(( diff / 60 )) hours ago"
        fi
    else
        if (( $diff > 1 )); then
            echo "$(( diff )) minutes ago"
        else
            echo "$(( now - ts )) seconds ago"
        fi
    fi
}


###
## @fn assert_pipe_status()
## @brief Assert that all commands in the last pipe
##        were executed successfully... or `die`
##
## @param args  All arguments are passed to the die function (e.g. -q or a message string)
##
## @see die()
##
###
assert_pipe_status() {
    local status=`echo "${PIPESTATUS[@]}" | tr -s ' ' 0`

    [[ "$status" -eq "0" ]] || die $@
}


###
## @fn assert_first_pipe_status()
## @brief Assert that the first command in the last pipe
##        were executed successfully... or `die`
##
## @param args  All arguments are passed to the die function (e.g. -q or a message string)
##
## @see die()
##
###
assert_first_pipe_status() {
    [[ "${PIPESTATUS[0]}" -eq "0" ]] || die $@
}


###
## @fn rename_function()
## @brief This function renames an existing function.
##
## It is guaranteed that a function with the new name will exists,
## even if the source function does not exist.
##
## In that case the newly created function is a empty function of course.
## This makes it easy and safe to build a chain of function calls.
##
## @code
## rename_function myfunc prev_myfunc
## myfunc() { prev_myfunc; dostuff; }
## @endcode
##
## @param functionName     The name of the function
## @param newFunctionName  The new name of the function
##
## @see copy_function()
###
rename_function() {
    local funcName="$1"
    local newFuncName="$2"

    local func=$(declare -f ${funcName})
    [[ -n "$func" ]] || func="$funcName() { true; }"

    eval "$newFuncName${func#$funcName}"
}

###
## @fn copy_function()
## @brief This function renames an existing function.
##
## It is guaranteed that a function with the new name will exists,
## even if the source function does not exist.
##
## In that case the newly created function is a empty function of course.
##
## @param functionName          The name of the function
## @param newFunctionName       The new name of the function
##
## @see rename_function()
###
copy_function() {
    local funcName="$1"
    local newFuncName="$2"

    local func=$(declare -f ${funcName})
    [[ -n "$func" ]] || func="$funcName() { true; }"

    eval "$newFuncName${func#$funcName}"
}


###
## @fn to_win_path()
## @brief This function converts a unix path to a windows path.
##
## @param path  A unix file path
###
to_win_path() {
    local path=${1}
    local result="$(readlink -e ${path} | sed -e 's/^\///' -e 's/\//\\/g' -e 's/^./\0:/' -e 's/::/:/')"

    echo $result
}

###
## @fn call()
## @brief call a function or die if it does not exist
##
## @param function_name  The function name
## @param params         The function's parameters
###
call() {
    local function_name="${1}"
    if is_function "${function_name}"; then
        shift
        ${function_name} "$@"
    else
        die "Function not found: ${function_name}"
    fi
}

# vi: set shiftwidth=4 tabstop=4 expandtab:
