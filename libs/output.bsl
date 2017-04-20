#!/bin/bash

###
## @file
## @ingroup lib
## @brief Output utility functions
###

###
# PRIVATE colors [$enable]
#
# Defines some variables initialized with vt100 color escape sequenzes or,
# if the first argument is none (no, nee, ... starts with n), as empty strings.
###
colors() {
    if [[ $1 != n* ]]; then
        COLOR_ENABLED=1
        COLOR_NORMAL=$(tput sgr0)
        COLOR_BOLD=$(tput bold)
        COLOR_RED=$(tput setaf 1)
        COLOR_GREEN=$(tput setaf 2)
        COLOR_YELLOW=$(tput setaf 3)
        COLOR_BLUE=$(tput setaf 4)
        COLOR_MAGENTA=$(tput setaf 5)
        COLOR_CYAN=$(tput setaf 6)
        COLOR_WHITE=$(tput setaf 7)
    else
        # disable all colors
        COLOR_ENABLED=0
        COLOR_NORMAL=""
        COLOR_BOLD=""
        COLOR_RED=""
        COLOR_GREEN=""
        COLOR_YELLOW=""
        COLOR_BLUE=""
        COLOR_MAGENTA=""
        COLOR_CYAN=""
        COLOR_WHITE=""
    fi

    COLOR_HI=${COLOR_BLUE}${COLOR_BOLD}
    COLOR_WARN=${COLOR_RED}${COLOR_BOLD}
    COLOR_ERROR=${COLOR_WARN}
    COLOR_LIST_HEADER=${COLOR_GREEN}${COLOR_BOLD}
    COLOR_LIST_LEFT=${COLOR_BOLD}
    COLOR_LIST_RIGHT=${COLOR_NORMAL}
    COLOR_BG_BLACK=$(tput setab 0)
}

colors_enabled() {
    local on_true="$1"
    local on_false="$2"

    if [ $COLOR_ENABLED -eq 1 ] ; then
        echo $on_true
        exit 0
    fi

    echo $on_false
    exit 1
}

change_color(){
    echo -ne "${1}" 1>&2
}

reset_color(){
    echo -ne "${COLOR_NORMAL}" 1>&2
}

write_bold() {
    echo -e "${COLOR_BOLD}${*}${COLOR_NORMAL}" 1>&2
}

write_bold_red() {
    echo -e "${COLOR_RED}${COLOR_BOLD}${*}${COLOR_NORMAL}" 1>&2
}

write_norm_red() {
    echo -e "${COLOR_RED}${*}${COLOR_NORMAL}" 1>&2
}

write_bold_green() {
    echo -e "${COLOR_GREEN}${COLOR_BOLD}${*}${COLOR_NORMAL}" 1>&2
}

write_norm_green() {
    echo -e "${COLOR_GREEN}${*}${COLOR_NORMAL}" 1>&2
}

write_bold_yellow() {
    echo -e "${COLOR_YELLOW}${COLOR_BOLD}${*}${COLOR_NORMAL}" 1>&2
}

write_norm_yellow() {
    echo -e "${COLOR_YELLOW}${*}${COLOR_NORMAL}" 1>&2
}

write_bold_blue() {
    echo -e "${COLOR_BLUE}${COLOR_BOLD}${*}${COLOR_NORMAL}" 1>&2
}

write_norm_blue() {
    echo -e "${COLOR_BLUE}${*}${COLOR_NORMAL}" 1>&2
}

write_bold_magenta() {
    echo -e "${COLOR_MAGENTA}${COLOR_BOLD}${*}${COLOR_NORMAL}" 1>&2
}

write_norm_magenta() {
    echo -e "${COLOR_MAGENTA}${*}${COLOR_NORMAL}" 1>&2
}

write_bold_cyan() {
    echo -e "${COLOR_CYAN}${COLOR_BOLD}${*}${COLOR_NORMAL}" 1>&2
}

write_norm_cyan() {
    echo -e "${COLOR_CYAN}${*}${COLOR_NORMAL}" 1>&2
}

write_bold_white() {
    echo -e "${COLOR_WHITE}${COLOR_BOLD}${*}${COLOR_NORMAL}" 1>&2
}

write_norm_white() {
    echo -e "${COLOR_WHITE}${*}${COLOR_NORMAL}" 1>&2
}


###
# PUBLIC write_norm_highlight $msg
#
# Print $msg in a highlighted way, but with normal font metrics
###
write_norm_highlight() {
    write_norm_blue ${*}
}

###
# PUBLIC write_bold_highlight $msg
#
# Print $msg in a highlighted way and with a bold font style
###
write_bold_highlight() {
    write_bold_blue ${*}
}


write_block_done() {
     [ -z $1 ] || echo -n "["
     echo -en "${COLOR_BG_BLACK}${COLOR_BOLD}${COLOR_GREEN} done ${COLOR_NORMAL}" 1>&2
     [ -z $1 ] || echo -n "]"
     echo
}


write_block_ok() {
     [ -z $1 ] || echo -n "["
     echo -en "${COLOR_BG_BLACK}${COLOR_BOLD}${COLOR_GREEN}  ok  ${COLOR_NORMAL}" 1>&2
     [ -z $1 ] || echo -n "]"
     echo
}


write_block_skip() {
     [ -z $1 ] || echo -n "["
     echo -en "${COLOR_BG_BLACK}${COLOR_BOLD}${COLOR_YELLOW} skip ${COLOR_NORMAL}" 1>&2
     [ -z $1 ] || echo -n "]"
     echo
}


write_block_fail() {
     [ -z $1 ] || echo -n "["
     echo -en "${COLOR_BG_BLACK}${COLOR_BOLD}${COLOR_RED} fail ${COLOR_NORMAL}" 1>&2
     [ -z $1 ] || echo -n "]"
     echo
}


###
# PUBLIC set_output_mode
#
# set output mode to $1
###
set_output_mode() {
    BASF_OUTPUT_MODE=$1
}


###
# PUBLIC is_output_mode
#
# test if $1 is the current output mode
###
is_output_mode() {
    [[ ${BASF_OUTPUT_MODE} = $1 ]]
}


###
# PRIVATE init_columns
#
# Determine width of terminal and set COLUMNS variable
###
init_columns() {
    [[ -n ${COLUMNS} ]] || COLUMNS=$(tput cols) || COLUMNS=80
}


###
# PUBLIC write_error_msg msg
#
# Display error message $msg
###
write_error_msg() {
    echo -e "${COLOR_ERROR}!!! Error: ${COLOR_NORMAL}${*}" 1>&2
}


###
# PUBLIC write_warning_msg msg
#
# Display warning message $msg
###
write_warning_msg() {
    echo -e "${COLOR_WARN}!!! Warning: ${COLOR_NORMAL}${*}" 1>&2
}


###
# PUBLIC write_info_msg msg
#
# Display warning message $msg
###
write_info_msg() {
    echo -e "${COLOR_HI}!!! Info: ${COLOR_NORMAL}${*}" 1>&2
}


###
# PUBLIC write_list_start
#
# Write a list headline. If -p is passed, the output is forced to plain.
###
write_list_start() {
    is_output_mode brief && return

    local color=${COLOR_LIST_HEADER} normal=${COLOR_NORMAL}
    if [[ $1 == "-p" ]]; then
        color=; normal=
        shift
    fi

    echo -n -e "${color}"
    echo -n -e "$(apply_text_highlights "${color}" "$*")"
    echo -n -e "${normal}"
    echo
}


###
# PUBLIC write_kv_list_entry
#
# Write a key/value list entry with $1 on the left and $2 on the right.
###
write_kv_list_entry() {
    local n text key val lindent rindent
    local left=${COLOR_LIST_LEFT} right=${COLOR_LIST_RIGHT}
    local normal=${COLOR_NORMAL}
    local cols=${COLUMNS:-80}
    local IFS=$' \t\n'

    if [[ $1 == "-p" ]]; then
        left=; right=; normal=
        shift
    fi

    lindent=${1%%[^[:space:]]*}
    rindent=${2%%[^[:space:]]*}
    key=${1##*([[:space:]])}
    val=${2##*([[:space:]])}

    echo -n -e "  ${lindent}${left}"
    echo -n -e "$(apply_text_highlights "${left}" "${key}")"
    echo -n -e "${normal}"

    text=${key//\%%%??%%%/}
    n=$(( 26 + ${#rindent} - ${#lindent} - ${#text} ))

    text=${val//\%%%??%%%/}
    if [[ -z ${text} ]]; then
        # empty ${val}: end the line and be done
        echo
        return
    fi

    # if ${n} is less than or equal to zero then we have a long ${key}
    # that will mess up the formatting of ${val}, so end the line, indent
    # and let ${val} go on the next line. Don't start a new line when
    # in brief output mode, in order to keep the output easily parsable.
    if [[ ${n} -le 0 ]]; then
        if is_output_mode brief; then
            n=1
        else
            echo
            n=$(( 28 + ${#rindent} ))
        fi
    fi

    echo -n -e "$(space ${n})${right}"
    n=$(( 28 + ${#rindent} ))

    # only loop if it doesn't fit on the same line
    if [[ $(( ${n} + ${#text} )) -ge ${cols} ]] && ! is_output_mode brief; then
        local i=0 spc=""
        rindent=$(space ${n})
        local cwords=( $(apply_text_highlights "${right}" "${val}") )
        for text in ${val}; do
            text=${text//\%%%??%%%/}
            # put the word on the same line if it fits
            if [[ $(( ${n} + ${#spc} + ${#text} )) -lt ${cols} ]]; then
                echo -n -e "${spc}${cwords[i]}"
                n=$(( ${n} + ${#spc} + ${#text} ))
            # otherwise, start a new line and indent
            else
                echo -n -e "\n${rindent}${cwords[i]}"
                n=$(( ${#rindent} + ${#text} ))
            fi
            (( i++ ))
            spc=" "
        done
    else
        echo -n -e "$(apply_text_highlights "${right}" "${val}")"
    fi
    echo -e "${normal}"
}


###
# PUBLIC write_numbered_list_entry
#
###
write_numbered_list_entry() {
    local left=${COLOR_LIST_LEFT}
    local right=${COLOR_LIST_RIGHT}
    local normal=${COLOR_NORMAL}
    local extra=${COLOR_HI}

    if [[ $1 == "-p" ]]; then
        left=; right=; normal=
        shift
    fi

    if ! is_output_mode brief; then
        echo -n -e "  ${left}"
        echo -n -e "[$(apply_text_highlights "${left}" "$1")]"
        echo -n -e "${normal}"
        space $(( 4 - ${#1} ))
    fi

    echo -n -e "${right}"
    echo -n -e "$(apply_text_highlights "${right}" "$2")"
    space $(( 14 - ${#2} ))
    [[ -n "$3" ]] && echo -n $3 && space $(( 26 - ${#3} ))
    echo -ne "${normal}"

    if ! is_output_mode brief; then
        echo -n -e "  ${extra}"
        echo -n -e "$(apply_text_highlights "${extra}" "$4")"
        echo -n -e "${normal}"
    fi

    echo -e "${normal}"
}


###
# PRIVATE apply_text_highlights
#
# Apply text highlights.
# First arg is the restore color, second arg is the text.
###
apply_text_highlights() {
    local restore=${1:-${COLOR_NORMAL}} text=$2
    text="${text//?%%HI%%%/${COLOR_HI}}"
    text="${text//?%%WA%%%/${COLOR_WARN}}"
    text="${text//?%%RE%%%/${restore}}"
    echo -n "${text}"
}


###
# PUBLIC highlight
#
# Highlight all arguments. Text highlighting function.
###
highlight() {
    echo -n "%%%HI%%%${*}%%%RE%%%"
}


###
# PUBLIC highlight_warning
# Highlight all arguments as a warning (red). Text highlighting function.
###
highlight_warning() {
    echo -n "%%%WA%%%${*}%%%RE%%%"
}


###
# PUBLIC highlight_marker
#
# Mark list entry $1 as active/selected by placing a highlighted
# star (or $2 if set) behind it.
###
highlight_marker() {
    local text=$1 mark=${2-*}
    echo -n "${text}"
    if [[ -n ${mark} ]] && ! is_output_mode brief; then
        echo -n " "
        highlight "${mark}"
    fi
}


###
# PUBLIC space
#
# Write $1 numbers of '$2' characters (default spaces)
###
space() {
    local n=$1
    local c="$2"
    [[ -z $c ]] && c=' '

    while (( n-- > 0 )); do
        echo -n "$c"
    done
}

##
# PUBLIC lfill $text $count
#
# Echo the $text with at least $count characters. If width of $text is shorter
# than $count characters, then the missing characters are padded by spaces.
##
print_without_colors() {
    echo $1 | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
}

##
# PUBLIC lfill $text $count
#
# Echo the $text with at least $count characters. If width of $text is shorter
# than $count characters, then the missing characters are padded by spaces.
##
lfill() {
    local text="$1"
    local n=$2
    local c="$3"
    local plain=`print_without_colors "$text"`
    space $(( $n - ${#plain} )) $c
    echo -n $text
}


##
# PUBLIC rfill $text $count $char
#
# Echo the $text with at least $count characters. If width of $text is shorter
# than $count characters, then the missing characters are padded by $char
# (default spaces).
##
rfill() {
    local text="$1"
    local n=$2
    local c="$3"
    local plain=`print_without_colors "$text"`

    echo -n $text
    space $(( $n - ${#plain} )) $c
}

# vi: set shiftwidth=4 tabstop=4 expandtab:
