#!/usr/bin/env bash

#  Script: hhs-shell-utils.bash
# Created: Oct 5, 2019
#  Author: <B>H</B>ugo <B>S</B>aporetti <B>J</B>unior
#  Mailto: homesetup@gmail.com
#    Site: https://github.com/yorevs/homesetup
# License: Please refer to <https://opensource.org/licenses/MIT>
#
# Copyright (c) 2023, HomeSetup team

# !NOTICE: Do not change this file. To customize your functions edit the file ~/.functions

# @function: Search for previously issued commands from history using filters.
# @param $1 [Req] : The case-insensitive filter to be used when listing.
function __hhs_history() {

  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: ${FUNCNAME[0]} [regex_filter]"
    return 1
  elif [[ "$#" -eq 0 ]]; then
    history | sort -k2 -k 1,1nr | uniq -f 1 | sort -n | grep -i "^ *[0-9]*  "
  else
    history | sort -k2 -k 1,1nr | uniq -f 1 | sort -n | grep -i "$*"
  fi

  return $?
}

# inspiRED by https://superuser.com/questions/250227/how-do-i-see-what-my-most-used-linux-command-are
# @function: Display statistics about commands in history.
# @param $1 [Opt] : Limit to the top N commands.
function __hhs_hist_stats() {

  local top_n=${1:-10} i=1 cmd_name cmd_qty cmd_chart

  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: ${FUNCNAME[0]} [top_N]"
    return 1
  fi

  pad=$(printf '%0.1s' "."{1..60})
  pad_len=30

  echo -e "\n${ORANGE}Top '${top_n}' used commands in bash history ...\n"
  for cmd in $(history | tr -s ' ' | cut -d ' ' -f6 | sort | uniq -c | sort -nr | head -n "${top_n}" |
    perl -lane 'printf "%s %03d %s \n", $F[1], $F[0], "▄" x ($F[0] / 5)'); do
    cmd_name=$(echo "${cmd}" | cut -d ' ' -f1)
    cmd_qty=$(echo "${cmd}" | cut -d ' ' -f2)
    cmd_chart=$(echo "${cmd}" | cut -d ' ' -f3-)
    printf "${WHITE}%3d: ${HHS_HIGHLIGHT_COLOR} " $i
    echo -n "${cmd_name} "
    printf '%*.*s' 0 $((pad_len - ${#cmd_name})) "${pad}"
    printf "${GREEN}%s ${CYAN}|%s \n" " ${cmd_qty}" "${cmd_chart}"
    i=$((i+1))
  done
  echo "${NC}"

  return $?
}

# @function: Display all environment variables using filters.
# @param $1 [Opt] : If -e is present, edit the env file, otherwise a case-insensitive filter to be used when listing.
function __hhs_envs() {

  local pad pad_len filters name value columns ret_val=0

  HHS_ENV_FILE=${HHS_ENV_FILE:-$HHS_DIR/.env}

  touch "${HHS_ENV_FILE}"

  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: ${FUNCNAME[0]} [options] [regex_filters]"
    echo ''
    echo '    Options: '
    echo '      -e : Edit current HHS_ENV_FILE.'
    return 1
  else
    if [[ "$1" == '-e' ]]; then
      __hhs_edit "${HHS_ENV_FILE}"
      ret_val=$?
    else
      pad=$(printf '%0.1s' "."{1..60})
      pad_len=40
      columns="$(($(tput cols) - pad_len - 10))"
      filters="$*"
      filters=${filters// /\|}
      [[ -z "${filters}" ]] && filters=".*"
      echo ' '
      echo "${YELLOW}Listing all exported environment variables matching [ ${filters} ]:${NC}"
      echo ' '
      IFS=$'\n'
      shopt -s nocasematch
      for v in $(env | sort); do
        name=${v%%=*}
        value=${v#*=}
        if [[ ${name} =~ ${filters} ]]; then
          echo -en "${HHS_HIGHLIGHT_COLOR}${name}${NC} "
          printf '%*.*s' 0 $((pad_len - ${#name})) "${pad}"
          echo -en " ${GREEN}=> ${NC}"
          echo -n "${value:0:${columns}}"
          [[ ${#value} -ge ${columns} ]] && echo -n "..."
          echo "${NC}"
        fi
      done
      shopt -u nocasematch
      IFS="$RESET_IFS"
      echo ' '
    fi
  fi

  return ${ret_val}
}

# @function: Display all alias definitions using filters.
# @param $1 [Opt] : If -e is present, edit the .aliasdef file, otherwise a case-insensitive filter to be used when listing.
function __hhs_defs() {

  local pad pad_len filters name value columns ret_val=0

  HHS_ALIASDEF_FILE="${HHS_DIR}/.aliasdef"

  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: ${FUNCNAME[0]} [regex_filters]"
    return 1
  else
    if [[ "$1" == '-e' ]]; then
      __hhs_edit "${HHS_ALIASDEF_FILE}"
      ret_val=$?
    else
      pad=$(printf '%0.1s' "."{1..60})
      pad_len=51
      columns="$(($(tput cols) - pad_len - 10))"
      filters="$*"
      filters=${filters// /\|}
      [[ -z "${filters}" ]] && filters=".*"
      echo ' '
      echo "${YELLOW}Listing all alias definitions matching [ ${filters} ]:"
      echo ' '
      IFS=$'\n'
      shopt -s nocasematch
      # shellcheck disable=SC2013
      for v in $(grep '^ *__hhs_alias' "${HHS_ALIASDEF_FILE}" | sed 's/^ *//g' | sort | uniq); do
        name=${v%%=*}
        name=${name// /}
        value=${v#*=}
        value=${value//\'/}
        if [[ ${name} =~ ${filters} ]]; then
          echo -en "${HHS_HIGHLIGHT_COLOR}${name//__hhs_alias/}${NC} "
          printf '%*.*s' 0 $((pad_len - ${#name})) "${pad}"
          echo -en " ${GREEN}is defined as ${NC}"
          echo -n "${value:0:${columns}}"
          [[ ${#value} -ge ${columns} ]] && echo -n "..."
          echo "${NC}"
        fi
      done
      shopt -u nocasematch
      IFS="$RESET_IFS"
      echo ' '
    fi
  fi

  return ${ret_val}
}

# @function: Select a shell from the existing shell list.
function __hhs_shell_select() {

  local ret_val=1 sel_shell mselect_file avail_shells=()

  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: ${FUNCNAME[0]} "
  else
    IFS=$'\n' read -d '' -r -a avail_shells <<<"$(grep '/.*' '/etc/shells')"
    # Add the brew bash and zsh as options
    [[ -f '/usr/local/bin/bash' ]] && avail_shells+=('/usr/local/bin/bash')
    [[ -f '/usr/local/bin/zsh' ]] && avail_shells+=('/usr/local/bin/zsh')
    mselect_file=$(mktemp)
    if __hhs_mselect "${mselect_file}" "Please select your new default shell:" "${avail_shells[@]}"; then
      sel_shell=$(grep . "${mselect_file}")
      if [[ -n "${sel_shell}" && -f "${sel_shell}" ]]; then
        if \chsh -s "${sel_shell}"; then
          ret_val=$?
          clear
          export SHELL="${sel_shell}"
          echo "${GREEN}Your default shell has changed to => '${SHELL}'"
          echo "${ORANGE}Next time you open a terminal window you will use \"${SHELL}\" as your default shell"
          \rm -f "${mselect_file}"
        else
          __hhs_errcho "${FUNCNAME[0]}: Unable to change shell to ${sel_shell}"
          [[ -f "${mselect_file}" ]] && \rm -f "${mselect_file}"
        fi
      fi
    fi
    IFS="$RESET_IFS"
    echo -e "${NC}"
  fi

  return ${ret_val}
}
