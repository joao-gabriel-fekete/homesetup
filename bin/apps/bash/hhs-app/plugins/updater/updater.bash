#!/usr/bin/env bash
#shellcheck disable=SC2181,SC2034,SC1090

#  Script: updater.bash
# Purpose: HomeSetup update manager
# Created: Oct 5, 2019
#  Author: <B>H</B>ugo <B>S</B>aporetti <B>J</B>unior
#  Mailto: yorevs@hotmail.com
#    Site: https://github.com/yorevs/homesetup
# License: Please refer to <https://opensource.org/licenses/MIT>
# !NOTICE: Do not change this file. To customize your functions edit the file ~/.functions

# Current script version.
VERSION=0.9.0

# Current plugin name
PLUGIN_NAME="updater"

# Usage message
USAGE="
 _   _           _       _            
| | | |_ __   __| | __ _| |_ ___ _ __ 
| | | | '_ \ / _\` |/ _\` | __/ _ \ '__|
| |_| | |_) | (_| | (_| | ||  __/ |   
 \___/| .__/ \__,_|\__,_|\__\___|_|   
      |_|                             

HomeSetup update manager.

Usage: ${PLUGIN_NAME} ${PLUGIN_NAME} [option] {check,update,stamp}

    Options:
      -v  |   --version : Display current program version.
      -h  |      --help : Display this help message.
      
    Arguments:
      check             : Fetch the last_update timestamp and check if HomeSetup needs to be updated.
      update            : Check the current HomeSetup installation and look for updates.
      stamp             : Stamp the next auto-update check for 7 days ahead.
"

UNSETS=(
  help version cleanup execute update_hhs stamp_next_update stamp_next_update is_greater
)

[[ -s "${HHS_DIR}/bin/app-commons.bash" ]] && source "${HHS_DIR}/bin/app-commons.bash"

# @purpose: Check whether the repository version is greater than installed version.
is_greater() {
  IFS='.' read -r -a curr_versions <<<"${HHS_VERSION}"
  IFS='.' read -r -a repo_versions <<<"${repo_ver}"
  for idx in "${!repo_versions[@]}"; do
    if [[ ${repo_versions[idx]} -gt ${curr_versions[idx]} ]]; then
      echo ''
      echo -e "${ORANGE}Your version of HomeSetup is not up-to-date: ${NC}"
      echo -e "  => Repository: ${GREEN}v${repo_ver}${NC}, Yours: ${RED}v${HHS_VERSION}${NC}"
      echo ''
      return 0
    fi
  done

  echo -e "${GREEN}Your version of HomeSetup is up-to-date v${HHS_VERSION}${NC}"

  return 1
}

# shellcheck disable=SC2120
# @purpose: Check the current HomeSetup installation and look for updates.
update_hhs() {

  local repo_ver is_different re
  local VERSION_URL='https://raw.githubusercontent.com/yorevs/homesetup/master/.VERSION'

  if [[ -n "${HHS_VERSION}" ]]; then
    clear
    repo_ver="$(curl --silent --fail --connect-timeout 1 --max-time 2 "${VERSION_URL}")"
    re="[0-9]+\.[0-9]+\.[0-9]+"

    if [[ ${repo_ver} =~ $re ]]; then
      if is_greater "${repo_ver}"; then
        read -r -n 1 -sp "${YELLOW}Would you like to update it now (y/[n]) ?" ANS
        [[ -n "$ANS" ]] && echo "${ANS}${NC}"
        if [[ "$ANS" == 'y' || "$ANS" == 'Y' ]]; then
          pushd "${HHS_HOME}" &>/dev/null || quit 1
          git pull || quit 1
          popd &>/dev/null || quit 1
          if "${HHS_HOME}"/install.bash -q; then
            echo -e "${GREEN}Successfully updated HomeSetup !"
            source ~/.bashrc
            echo -e "${HHS_MOTD}"
          else
            quit 1 "${PLUGIN_NAME}: Failed to install HomeSetup update !${NC}"
          fi
        fi
      fi
      stamp_next_update &>/dev/null
    else
      quit 1 "${PLUGIN_NAME}: Unable to fetch repository version !"
    fi
  else
    quit 1 "${PLUGIN_NAME}: HHS_VERSION was not defined !"
  fi
  echo -e "${NC}"

  quit 0
}

# @purpose: Fetch the last_update timestamp and check if HomeSetup needs to be updated.
update_check() {

  local today next_check

  today=$(date "+%s%S")
  cur_check=$(grep . "${HHS_DIR}"/.last_update)
  next_check=$(stamp_next_update)
  if [[ ${today} -ge ${cur_check} ]]; then
    update_hhs
    return $?
  fi

  return 0
}

# @purpose: Stamp the next update timestamp
stamp_next_update() {

  local next_check

  if [[ ! -f "${HHS_DIR}/.last_update" ]]; then
    # Stamp the next update check for today
    next_check=$(date "+%s%S")
  else
    # Stamp the next update check for next week
    if [[ "Darwin" == "${HHS_MY_OS}" ]]; then
      next_check=$(date -v+7d '+%s%S')
    else
      next_check=$(date -d '+7 days' '+%s%S')
    fi
  fi
  echo "${next_check}" >"${HHS_DIR}/.last_update"
  echo "${next_check}"

  return 0
}

# @purpose: HHS plugin required function
function help() {
  usage 0
}

# @purpose: HHS plugin required function
function version() {
  echo "HomeSetup ${PLUGIN_NAME} plugin v${VERSION}"
  quit 0
}

# @purpose: HHS plugin required function
function cleanup() {
  unset "${UNSETS[@]}"
  echo -n ''
}

# @purpose: HHS plugin required function
function execute() {

  [[ -z "$1" || "$1" == "-h" || "$1" == "--help" ]] && usage 0
  [[ "$1" == "-v" || "$1" == "--version" ]] && version

  cmd="$1"
  shift
  args=("$@")

  shopt -s nocasematch
  case "$cmd" in
    check)
      update_check
    ;;
    update)
      update_hhs
    ;;
    stamp)
      stamp_next_update
    ;;
    *)
      usage 1 "Invalid ${PLUGIN_NAME} command: \"${cmd}\" !"
    ;;
  esac
  shopt -u nocasematch

  quit 0
}
