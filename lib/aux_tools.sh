#!/usr/bin/env bash

declare -r NMAP=`which nmap`
declare -r SEARCHSPLOIT=`which searchsploit`
declare -r DIRB=`which dirb`
declare -r NIKTO=`which nikto`
declare -r SMBCLIENT=`which smbclient`
declare -r CURL=`which curl`
declare -r WHATWEB=`which whatweb`
declare -r WFUZZ=`which wfuzz`
declare -r DAVTEST=`which davtest`
declare -r SQLMAP=`which sqlmap`
declare -r UNICORN=`which unicornscan`


function test_and_exit_if_not_found() {
  if [ ! -x $1 ]; then
    error "can't find $1 executable"
    exit 1
  fi
  return 1
}

function test_and_warn_if_not_found() {
  if [ ! -x $1 ]; then
    warn "can't find $1 executable"
    return 0
  fi
  return 1
}
