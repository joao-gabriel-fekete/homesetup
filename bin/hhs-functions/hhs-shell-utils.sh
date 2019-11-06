#!/usr/bin/env bash

#  Script: hhs-shell-utils.sh
# Created: Oct 5, 2019
#  Author: <B>H</B>ugo <B>S</B>aporetti <B>J</B>unior
#  Mailto: yorevs@hotmail.com
#    Site: https://github.com/yorevs/homesetup
# License: Please refer to <http://unlicense.org/>
# !NOTICE: Do not change this file. To customize your functions edit the file ~/.functions

# @function: Search for previous issued commands from history using filters.
# @param $1 [Req] : The searching command.
function __hhs_history() {

    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "Usage: ${FUNCNAME[0]} [command]"
        return 1
    elif [ "$#" -eq 0 ]; then
        history | sort -k2 -k 1,1nr | uniq -f 1 | sort -n | grep "^ *[0-9]*  "
    else
        history | sort -k2 -k 1,1nr | uniq -f 1 | sort -n | grep "$*"
    fi

    return 0
}

# @function: Prints all environment variables on a separate line using filters.
# @param $1 [Opt] : Filter environments.
function __hhs_envs() {

    local pad pad_len filter name value columns

    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "Usage: ${FUNCNAME[0]} [regex_filter]"
        return 1
    else
        pad=$(printf '%0.1s' "."{1..60})
        pad_len=40
        columns="$(($(tput cols)-pad_len-9))"
        filter="$*"
        [ -z "$filter" ] && filter="^[a-zA-Z0-9_]*.*"
        echo ' '
        echo "${YELLOW}Listing all exported environment variables matching [ $filter ]:"
        echo ' '
        (
            IFS=$'\n'
            shopt -s nocasematch
            for v in $(env | sort); do
                name=$(echo "$v" | cut -d '=' -f1)
                value=$(echo "$v" | cut -d '=' -f2-)
                if [[ ${name} =~ ${filter} ]]; then
                    echo -en "${HIGHLIGHT_COLOR}${name}${NC} "
                    printf '%*.*s' 0 $((pad_len - ${#name})) "$pad"
                    echo -n " ${GREEN}=> ${NC}${value:0:$columns} "
                    [ "${#value}" -ge "$columns" ] && echo "...${NC}" || echo "${NC}"
                fi
            done
            shopt -u nocasematch
            IFS="$RESET_IFS"
        )
        echo ' '
    fi

    return 0
}