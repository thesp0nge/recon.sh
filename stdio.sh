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
declare -r VERSION="0.10"
declare -r OUTPUT_FOLDER_BASE=$HOME/$APPNAME/


function greeting() {
  echo "$APPNAME v$VERSION - paolo@codiceinsicuro.it"
}

function usage() {
  greeting
  echo "$APPNAME gathers information against a specific server."
	echo "Such information can be useful to find a way to get into that server in a penetration test."
	echo 
  echo "usage: $APPNAME [-vh] -i ip -p port -P protocol"
  echo -e "\t-v\tshows version"
  echo -e "\t-h\tprints this help"
  echo -e "\t-i ip\tuse ip address as scan argument"
	echo -e "\t-p port\tfocus on given port number"
	echo -e "\t-P protocol\tlaunch available protocol tests"
	echo
	echo -e "Available protocols are:"
	echo -e "\t* ftp"
	echo -e "\t* ssh"
	echo -e "\t* smtp"
	echo -e "\t* dns"
	echo -e "\t* smb"
	echo -e "\t* mysql"
	echo -e "\t* web"
  
}
function version() {
  echo $VERSION
}

function debug() {
  echo ${LYELLOW}"[`date +%H:%M:%S`] [DEBUG]" $APPNAME: $1${RESTORE}
}
function warning() {
  echo ${YELLOW}"[`date +%H:%M:%S`] [WARNING]" $APPNAME: $1${RESTORE}
}
function log() {
  echo ${WHITE}"[`date +%H:%M:%S`] [*]" $APPNAME: $1${RESTORE}
}
function info() {
  echo ${GREEN}"[`date +%H:%M:%S`] [INFO]" $APPNAME: $1${RESTORE}
}
function error() {
  echo ${RED}"[`date +%H:%M:%S`] [ERROR]" $APPNAME: $1${RESTORE}
}


