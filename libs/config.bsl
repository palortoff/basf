#!/bin/bash

###
## @file
## @ingroup lib
## @brief Library functions for working with configuration files.
###

###
## @fn read_config_value()
## @brief Load the value for key @p key from a configuration file @p file.
##
## @param file The file to read from
## @param key The key
##
## @note The configuration file must be a valid bash script, that is,
## the file must be loadable with 'source $file'.
##
###
read_config_value() {
    # exactly 2 parameter or die
    [[ ${#@} -eq 2 ]] || die

    local file=${1}
    local key=${2}

    # file exists and is readable?
    [[ -r "${file}" ]] || return 1

    # asign the output off the subshell to value.
    # In the subshell source the file and echo the value of the key.
    local value
    value=$(
             unset ${key}
             source ${file} 1>&2 > /dev/null || die "Failed to source ${file}."
             echo "${!key}"
          ) || exit $?

    # return the result
    echo "${value}"
    return 0
}


# vi: set shiftwidth=4 tabstop=4 expandtab:
