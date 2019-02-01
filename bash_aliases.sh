#!/usr/bin/env bash
# shellcheck disable=SC1117,SC2142

#  Script: bash_aliases.sh
# Purpose: This file is used to configure some useful shell aliases
# Created: Aug 26, 2008
#  Author: <B>H</B>ugo <B>S</B>aporetti <B>J</B>unior
#  Mailto: yorevs@hotmail.com
#    Site: https://github.com/yorevs/homesetup
# !NOTICE: Do not change this file. To customize your aliases edit the file ~/.aliases

# inspiRED by: https://github.com/mathiasbynens/dotfiles

# Removes all aliases before setting them
unalias -a

# -----------------------------------------------------------------------------------
# Navigational
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# shellcheck disable=SC2035,SC2139
alias ?='pwd'

# -----------------------------------------------------------------------------------
# General
alias q="exit"
alias reload='cls; source ~/.bashrc && echo "${GREEN}HomeSetup bash v$DOTFILES_VERSION reloaded!${NC}"'

# Kills all processes specified by $1
alias pk='function _() { test -n "$1" && plist $1 kill; };_'

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Always use color output for `ls`
alias ls='command ls ${COLOR_FLAG}'

# List all files colorized in long format
alias l='ls -lh'

# List all files colorized in long format, including dot files
alias ll='ls -lah'

# List all dotfiles
alias lll='ls -lhd .??* | grep "^-"'

# List all dotdirs
alias lld='ls -lhd .??*/'

# Always enable colored `grep` output
# Note: `GREP_OPTIONS="--color=auto"` is deprecated, hence the alias usage.
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# For safety, by default those commands will input for confirmation
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'

# Setting some defaults
alias cls='clear'
command -v vim >/dev/null && alias vi='vim'
alias tl='tail -F'
alias df='df -H'
alias du='du -ch'

# Make mount command output pretty and human readable format
alias mount='mount | column -t'

# Make a folder and cd into it
alias mkcd='function _() { mkdir -p $1; cd $1; };_'

# Top shortcut ordered by cpu
alias cpu='top -o cpu'

# Top shortcut ordered by Memory
alias mem='top -o rsize'

# Base64 encode shortcuts
alias encode="base64"

# Linux boxes have a different syntaxes for some commands, so we craete the alias to match the correct OS.
if [ "Linux" = "$(uname -s)" ]; then 
    alias ised="sed -i'' -r"
    alias decode='base64 -d'
elif [ "Darwin" = "$(uname -s)" ]; then
    alias ised="sed -i '' -E"
    alias decode='base64 -D'
fi

# Date and time shortcuts
alias week='date +%V'
alias now='date +"%d-%m-%Y %T"'
alias ts='date "+%s%S"'

# macOS has no `wget, so using curl instead`
command -v wget >/dev/null || alias wget='curl -O'

# Generate a random number int the range <min> <max>
alias rand='function _() { test -n "$1" -a -n "$2" && echo "$(( RANDOM % ($2 - $1 + 1 ) + $1 ))" || echo "Usage: rand <min> <max>"; };_'

# -----------------------------------------------------------------------------------
# Tool aliases

# Tree: List all directories recursively (Nth level depth) as a tree
command -v tree >/dev/null && alias lt='function _() { test -n "$1" -a -n "$2" && tree $1 -L $2 || tree $1; };_'

# Jenv: Set JAVA_HOME using jenv
command -v jenv >/dev/null && alias jenv_set_java_home='export JAVA_HOME="$HOME/.jenv/versions/`jenv version-name`"'

# Dropbox: Recursively delete Dropbox conflicted files from the current directory
test -d "$DROPBOX" && alias rmdbc="find . -name *\ \(*conflicted* -exec rm -v {} \;"

# -----------------------------------------------------------------------------------
# Python aliases

if command -v python > /dev/null; then

    # linux has no `json_pp`, so using python instead
    command -v json_pp >/dev/null || alias json_pp='python -m json.tool'
    
    # Evaluate mathematical expression
    alias calc='python -c "import sys,math; print(eval(\" \".join(sys.argv[1:])));"'

    # URL-encode strings
    alias urle='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'
    alias urld='python -c "import sys, urllib as ul; print ul.unquote_plus(sys.argv[1]);"'

    # Generate a UUID
    alias uuid='python -c "import uuid as ul; print(str(ul.uuid4()));"'
fi

# -----------------------------------------------------------------------------------
# IP related

# External IP
command -v dig >/dev/null && alias ip='dig +time=1 +short myip.opendns.com @resolver1.opendns.com'

# Local networking (requires pcregrep)
if command -v pcregrep > /dev/null; then
    # Show active network interfaces
    alias ifa="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"
    # Local IP of active interfaces
    alias ipl='for iface in $(ifa | grep -o "^en[0-9]\|^eth[0-9]"); do echo "Local($iface) IP : $(ipconfig getifaddr $iface)"; done'
fi

# All IPs of all interfaces
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# -----------------------------------------------------------------------------------
# Mac Stuff

# Delete all .DS_store files
alias clean-ds="find . -type f -name '*.DS_Store' -ls -delete"

# Flush Directory Service cache
command -v dscacheutil >/dev/null && alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

# Clean up LaunchServices to remove duplicates in the “Open With” menu
command -v lsregister >/dev/null && alias ls-cleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

# Show/hide hidden files in Finder
command -v defaults >/dev/null && alias show-files="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
command -v defaults >/dev/null && alias hide-files="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Canonical hex dump; some systems have this symlinked
command -v hd >/dev/null || alias hd='hexdump -C'

# macOS has no `md5sum`, so use `md5` as a fallback
command -v md5sum >/dev/null || alias md5sum='md5'

# macOS has no `sha1sum`, so use `shasum` as a fallback
command -v sha1 >/dev/null || alias sha1='shasum'
command -v sha1sum >/dev/null || alias sha1sum='sha1'

# -----------------------------------------------------------------------------------
# Git Stuff
if command -v git > /dev/null; then

    alias gs='git status'
    alias gf='git fetch'
    alias gh='git log -p'
    alias gco='git checkout'
    alias gta='git add'
    alias gb='git branch'
    alias gd='git diff'
    alias gp='git pull'
    alias gprb='git pull --rebase'
    alias gl='git log --oneline --graph --decorate'
    alias gcm='git commit -m'
    alias gca='git commit --amend --no-edit'
    alias gtps='git push origin HEAD'
    alias gba='function _() { test -n "$1" -a -n "$2" && for x in $(find "$1" -maxdepth 1 -type d -iname "$2"); do cd $x; pwd; git status | head -n 1; cd - > /dev/null; done || echo "Usage: gba <dirname> <fileext>"; };_'
    alias gsa='function _() { test -n "$1" && for x in $(find "$1" -maxdepth 1 -type d -iname "*.git"); do cd $x; pwd; git status; cd - > /dev/null; done || echo "Usage: gsa <dirname>"; };_'
    alias git-show='git diff-tree --no-commit-id --name-status -r'
    alias git-show-diff='function _() { git diff $1^1 $1 -- $2; };_'
fi

# -----------------------------------------------------------------------------------
# Gradle Stuff
if command -v gradle > /dev/null; then

    # Prefer using the wrapper instead of the command itself
    alias gw='function _() { [ -f "./gradlew" ] && ./gradlew $* || gradle $*; };_'
    alias gwb='gw clean build'
    alias gwr='gw bootRun'
    alias gwt='gw Test'
    alias gwi='gw init'
    alias gwq='gw -q'
    alias gww='gw wrapper --gradle-version'
fi

# -----------------------------------------------------------------------------------
# Docker stuff
if command -v docker > /dev/null; then

    alias drm='for next in $(docker volume ls -qf dangling=true); do echo "Removing Docker volume: $next"; docker volume rm $next; done'
fi

# -----------------------------------------------------------------------------------
# Directory Shortcuts

alias desk='cd $DESKTOP'
alias hhs='cd $HOME_SETUP'

# -----------------------------------------------------------------------------------
# Handy Terminal Shortcuts

# Show the cursor using tput
alias show-cursor='tput cnorm'

# Hide the cursor using tput
alias hide-cursor='tput civis'

# Save current cursor position
alias save-cursor-pos='tput sc'

# Restore saved cursor position
alias restore-cursor-pos='tput rc'

# Enable line wrapping
alias enable-line-wrap='echo -ne "\033[?7h"'

# Disable line wrapping
alias disable-line-wrap='echo -ne "\033[?7l"'

# -----------------------------------------------------------------------------------
# HomeSetup function aliases

alias encrypt='__hhs_encrypt'
alias decrypt='__hhs_decrypt'
alias hl='__hhs_hl'
alias sf='__hhs_sf'
alias sd='__hhs_sd'
alias ss='__hhs_ss'
alias hist='__hhs_hist'
alias del-tree='__hhs_del-tree'
alias jp='__hhs_jp'
alias ip-info='__hhs_ip-info'
alias ip-resolve='__hhs_ip-resolve'
alias ip-lookup='__hhs_ip-lookup'
alias port-check='__hhs_port-check'
alias envs='__hhs_envs'
alias paths='__hhs_paths'
alias ver='__hhs_ver'
alias tc='__hhs_tc'
alias tools='__hhs_tools'
alias mselect='__hhs_mselect'
alias aa='__hhs_aa'
alias save='__hhs_save'
alias load='__hhs_load'
alias cmd='__hhs_cmd'
alias punch='__hhs_punch'
alias plist='__hhs_plist'
alias godir='__hhs_godir'
alias git-='__hhs_git-'
alias sysinfo='__hhs_sysinfo'
alias parts='__hhs_parts'
alias dv='__hhs_dv'