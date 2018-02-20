#!/usr/bin/env bash

function basic_portscan_for_a_given_port() {
  if [ ! -f $2/scans/$1_regular_on_port_$3.nmap ]; then
    info "launching basic scan on port $3"
    $NMAP -sC -sV -v0 -A -T4 $1 -p $3 --reason -oA $2/scans/$1_regular_on_port_$3
  else
    warning "$2/scans/$1_regular_on_port_$3.nmap exists. Skipping scan"
  fi
}

function basic_portscan() {
  if [ ! -f $2/scans/$1_regular.nmap ]; then
    info "launching basic scan"
    $NMAP -sC -sV -v0 -A -T4 $1 --reason -oA $2/scans/$1_regular
  else
    warning "$2/scans/$1_regular.nmap exists. Skipping scan"
  fi
}

function full_portscan() {
  if [ ! -f $2/scans/$1_full.nmap ]; then
    info "launching full scan"
    $NMAP -v0 -p- -sT $1 --reason -oA $2/scans/$1_full
  else
    warning "$2/scans/$1_full.nmap exists. Skipping scan"
  fi
}


function udp_portscan() {
  if [ ! -f $2/scans/$1_udp.nmap ]; then
    info "launcing UDP full scan"
    $NMAP -v0 -p- -sU $1 --reason -oA $2/scans/$1_udp
  else
    warning "$2/scans/$1_udp.nmap exists. Skipping scan"
  fi
}
