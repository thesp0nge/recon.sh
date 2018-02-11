#!/usr/bin/env bash

declare -r RESTORE=$(echo -en '\033[0m')
declare -r RED=$(echo -en '\033[00;31m')
declare -r GREEN=$(echo -en '\033[00;32m')
declare -r YELLOW=$(echo -en '\033[00;33m')
declare -r BLUE=$(echo -en '\033[00;34m')
declare -r MAGENTA=$(echo -en '\033[00;35m')
declare -r PURPLE=$(echo -en '\033[00;35m')
declare -r CYAN=$(echo -en '\033[00;36m')
declare -r LIGHTGRAY=$(echo -en '\033[00;37m')
declare -r LRED=$(echo -en '\033[01;31m')
declare -r LGREEN=$(echo -en '\033[01;32m')
declare -r LYELLOW=$(echo -en '\033[01;33m')
declare -r LBLUE=$(echo -en '\033[01;34m')
declare -r LMAGENTA=$(echo -en '\033[01;35m')
declare -r LPURPLE=$(echo -en '\033[01;35m')
declare -r LCYAN=$(echo -en '\033[01;36m')
declare -r WHITE=$(echo -en '\033[01;37m')


declare -r APPNAME=$(basename $0)
declare -r VERSION="0.9"
declare -r OUTPUT_FOLDER_BASE=$HOME/$APPNAME/


function greeting() {
  echo "$APPNAME v$VERSION - paolo@codiceinsicuro.it"
}

function usage() {
  greeting
  echo "$APPNAME is a reconnaissance script to be used to collect information to be used in a penetration test."
  echo "usage: $APPNAME [-vh] -i ip"
  echo -e "\t-v\tshows version"
  echo -e "\t-h\tprints this help"
  echo -e "\t-i ip\tuse ip address as scan argument"
  
}
function version() {
  echo $VERSION
}

function debug() {
  echo ${LYELLOW}"[D]" $APPNAME: $1${RESTORE}
}
function warning() {
  echo ${YELLOW}"[*]" $APPNAME: $1${RESTORE}
}
function info() {
  echo ${GREEN}"[-]" $APPNAME: $1${RESTORE}
}
function error() {
  echo ${RED}"[!]" $APPNAME: $1${RESTORE}
}


