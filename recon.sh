#!/usr/bin/env bash
#
# recon.sh - reconnaissance script for first stage of a penetration test
# 
# Made with love, vim and shell by thesp0nge - paolo@codiceinsicuro.it
#
# Changelog
# 
# [0.10] - unreleased
#   Added
#     - colours
#
# [0.9] - 2018-02-06
#   Added
#     - first release on github
#     - '--reason' parameter to nmap
#     - UDP scanning
#     - attempt a curl call on website root directory
#     - add heartbleed specific test
#     - added whatweb against port 80 and 443
#     
# [0.8] - 2018-01-03
# 	Added
# 		- test_ftp for ftp testing
# 		- test_ssh for ssh testing
# 		- test_smtp for smtp testing
# 		- test_dns for dns testing
# 		- test_mysql for mysql testing
# 		- TCP port 139 for SMB protocol
# 	Changed
# 		- dirb and nikto filename
#
# [0.7] - 2017-11-20
# 	Added
# 		- sqlmap crawling website
# 		- support for HTTP routine for port 443 and 8080
# [0.6] - 2017-09-28
#   Added
#     - smbclient scan
#   Changed
#     - if nmap output is present on target directory, than scan is skipped and
#     file used for next step
# [0.5] - 2017-09-27
#   Added
#     - nmap, searchexploit, dirb and nikto scripting

RESTORE=$(echo -en '\033[0m')
RED=$(echo -en '\033[00;31m')
GREEN=$(echo -en '\033[00;32m')
YELLOW=$(echo -en '\033[00;33m')
BLUE=$(echo -en '\033[00;34m')
MAGENTA=$(echo -en '\033[00;35m')
PURPLE=$(echo -en '\033[00;35m')
CYAN=$(echo -en '\033[00;36m')
LIGHTGRAY=$(echo -en '\033[00;37m')
LRED=$(echo -en '\033[01;31m')
LGREEN=$(echo -en '\033[01;32m')
LYELLOW=$(echo -en '\033[01;33m')
LBLUE=$(echo -en '\033[01;34m')
LMAGENTA=$(echo -en '\033[01;35m')
LPURPLE=$(echo -en '\033[01;35m')
LCYAN=$(echo -en '\033[01;36m')
WHITE=$(echo -en '\033[01;37m')

function open_port_list() {

  case "$OSTYPE" in
    solaris*) echo "SOLARIS" ;;
    darwin*)  ports=$(grep -oE '\d{1,5}/open' $1 | cut -f 1 -d "/" | tr "\n" "," | sed 's/.$//') ;;
    linux*)   ports=$(grep -oP '\d{1,5}/open' $1 | cut -f 1 -d "/" | tr "\n" "," | sed 's/.$//') ;;
    bsd*)     echo "BSD" ;;
    msys*)    echo "WINDOWS" ;;
    *)        echo "unknown: $OSTYPE" ;;
  esac
  echo $ports
}
function greeting() {
  echo "$APPNAME v$VERSION - paolo@codiceinsicuro.it"
}

function help_me() {
  greeting
  echo -e "\n"
  echo "$APPNAME is a reconnaissance script to be used to collect information to be used in a penetration test."
}

function debug() {
  echo ${LYELLOW}"[D]"$1${RESTORE}
}
function warning() {
  echo ${YELLOW}$1${RESTORE}
}
function info() {
  echo ${GREEN}$1${RESTORE}
}
function error() {
  echo ${RED}$1 ${RESTORE}
}

function whatweb_web {
  if [ ! -x $WHATWEB ]; then
    warning "[!] whatweb not installed"
  else
    info "[*] launching whatweb on $1"
    $WHATWEB -v $1 > $OUTPUT_FOLDER_BASE$1/$1_whatweb
  fi
}
function fetch_http_web_root {
  if [ -z $2 ]; then
    port= 80
  else
    port= $2
  fi
  info "[*] fetching website root on $1 (port $port)" 
  $CURL -i -L http://$1 
}

function fetch_https_web_root {
  if [ -z $2 ]; then
    port= 443
  else
    port= $2
  fi
  info "[*] fetching website root on $1 (port $port) - HTTPS" 
  $CURL -i -L https://$1 
	$NMAP -sV -p $port --script=ssl-heartbleed.nse $1 -oA $OUTPUT_FOLDER_BASE$1/$1_$port_hearbleed
}


function test_ftp {
	info "[*] scanning FTP service"
	if [ -z $2 ]; then
		warning "[!] defaulting to FTP port 21"
		port=21
	else
		port=$2
	fi

	$NMAP -v0 -sT -p $port --script="ftp-anon.nse,ftp-bounce.nse,ftp-brute.nse,ftp-libopie.nse,ftp-proftpd-backdoor.nse,ftp-vsftpd-backdoor.nse,ftp-vuln-cve2010-4221.nse,tftp-enum.nse" $1 -oA $OUTPUT_FOLDER_BASE$1/$1_ftp
}

function test_ssh {
	info "[*] scanning SSH service"
	if [ -z $2 ]; then
		warning "[!] defaulting to SSH port 22"
		port=22
	else
		port=$2
	fi

	$NMAP -v0 -sT -p $port --script="ssh2-enum-algos.nse,ssh-hostkey.nse,sshv1.nse" $1 -oA $OUTPUT_FOLDER_BASE$1/$1_ssh
}


function test_smtp {
  info "[*] scanning SMTP service"
	if [ -z $2 ]; then
		warning "[!] defaulting to SMTP port 25"
		port=25
	else
		port=$2
	fi

	$NMAP -v0 -sT -p $port --script="smtp-brute.nse,smtp-commands.nse,smtp-enum-users.nse,smtp-ntlm-info.nse,smtp-open-relay.nse,smtp-strangeport.nse,smtp-vuln-cve2010-4344.nse,smtp-vuln-cve2011-1720.nse,smtp-vuln-cve2011-1764.nse" $1 -oA $OUTPUT_FOLDER_BASE$1/$1_smtp
}

function test_dns {
	info "[*] scanning DNS service"
	if [ -z $2 ]; then
		warning "[!] defaulting to DNS port 53"
		port=53
	else
		port=$2
	fi

	$NMAP -v0 -sT -p $port --script="broadcast-dns-service-discovery.nse,dns-blacklist.nse,dns-brute.nse,dns-cache-snoop.nse,dns-check-zone.nse,dns-client-subnet-scan.nse,dns-fuzz.nse,dns-ip6-arpa-scan.nse,dns-nsec3-enum.nse,dns-nsec-enum.nse,dns-nsid.nse,dns-random-srcport.nse,dns-random-txid.nse,dns-recursion.nse,dns-service-discovery.nse,dns-srv-enum.nse,dns-update.nse,dns-zeustracker.nse,dns-zone-transfer.nse,fcrdns.nse" $1  -oA $OUTPUT_FOLDER_BASE$1/$1_dns
}

function test_mysql {
	info "[*] scanning MYSQL service"
	if [ -z $2 ]; then
		warning "[!] defaulting to MYSQL port 3306"
		port=3306
	else
		port=$2
	fi

	$NMAP -v0 -sT -p $port --script="mysql-audit.nse,mysql-brute.nse,mysql-databases.nse,mysql-dump-hashes.nse,mysql-empty-password.nse,mysql-enum.nse,mysql-info.nse,mysql-query.nse,mysql-users.nse,mysql-variables.nse,mysql-vuln-cve2012-2122.nse" $1  -oA $OUTPUT_FOLDER_BASE$1/$1_mysql
}



function test_http {
	if [ -z $2 ]; then
		warning "[!] defaulting to HTTP website"
		secure=false
	else
		secure=$2
	fi

	if [ -z $3 ]; then
		if [ $secure == "false" ]; then
			warning "[!] defaulting to port 80"
			port=80
		fi
		if [ $secure == "true" ]; then
			warning "[!] defaulting to port 443"
			port=443
		fi
	else
		port=$3
	fi

  if [ -x $DIRB ]; then
		if [ ! -f $OUTPUT_FOLDER_BASE$1/$1_$port.dirb ]; then
			info "[*] launching dirb"
			if [ $secure == "false" ]; then
				$DIRB http://$1:$port -S -o $OUTPUT_FOLDER_BASE$1/$1_$port.dirb 2> /dev/null > /dev/null
			fi
			if [ $secure == "true" ]; then
				$DIRB https://$1:$port -S -o $OUTPUT_FOLDER_BASE$1/$1_$port.dirb 2> /dev/null > /dev/null
			fi
		else
			warning "[!] $OUTPUT_FOLDER_BASE$1/$1_$port.dirb exists. Skipping scan"
		fi
  else
    warning "[!] $APPNAME skipping dirb"
  fi

	if [ -x $NIKTO ]; then
		if [ ! -f $OUTPUT_FOLDER_BASE$1/$1_$port.nikto ]; then
			info "[*] launching nikto"
			if [ $secure == "false" ]; then
				$NIKTO -host http://$1 -port $port -Format txt -output $OUTPUT_FOLDER_BASE$1/$1_$port.nikto  2> /dev/null > /dev/null
			fi
			if [ $secure == "true" ]; then
				$NIKTO -host https://$1 -ssl -port $port -Format txt -output $OUTPUT_FOLDER_BASE$1/$1_$port.nikto  2> /dev/null > /dev/null
			fi
	else
			warning "[!] $OUTPUT_FOLDER_BASE$1/$1_$port.nikto exists. Skipping scan"
	fi
  else
    warning "[!] $APPNAME skipping nikto"
  fi

	warning "[!] you may want to manual launch $WFUZZ against $1"
	warning "[!] if DAV enabled you may want to launch $DAVTEST -url $1"

	if [ $secure == "true" ]; then 
		fetch_http_web_root
	else
		fetch_https_web_root
	fi

	whatweb_web

	if [ -x $SQLMAP ]; then
		info "[*] launching sqlmap"
		$SQLMAP -u http://$1 --crawl=3 --output-dir=$SAVEDIR --batch
	fi

}

NMAP=`which nmap`
SEARCHSPLOIT=`which searchsploit`
DIRB=`which dirb`
NIKTO=`which nikto`
SMBCLIENT=`which smbclient`
CURL=`which curl`
WHATWEB=`which whatweb`
WFUZZ=`which wfuzz`
DAVTEST=`which davtest`

SQLMAP=`which sqlmap`


APPNAME=`basename $0`
VERSION="0.9"
OUTPUT_FOLDER_BASE=./

# Be polite. Say hello. It starts from here.
greeting

# Without nmap there is no way to go further.
if [ ! -x $NMAP ]; then
  error "$APPNAME: can't find nmap executable"
  exit 1
fi

if [ "$#" -ne 1 ]; then
  error "$APPNAME: missing target"
  echo "usage: $APPNAME: ip_address"
  exit 1
fi

SAVEDIR=$OUTPUT_FOLDER_BASE$1
info "[*] $APPNAME is recon $1. Saving results in $SAVEDIR"
mkdir -p $SAVEDIR
touch $SAVEDIR/notes.txt

if [ ! -f $SAVEDIR/$1_regular.nmap ]; then
  info "[*] launcing regular scan"
  $NMAP -sC -sV -v0 -A -T4 $1 --reason -oA $SAVEDIR/$1_regular
else
  warning "[!] $SAVEDIR/$1_regular.nmap exists. Skipping scan"
fi

ports=$(open_port_list $SAVEDIR/$1_regular.gnmap)
info "Interesting TCP ports found $ports"


fine=`grep 21 $OUTPUT_FOLDER_BASE$1/$1_regular.gnmap | cut -f2 -d"/"`
if [ "$fine" == "open" ]; then
	test_ftp $1 21
fi

fine=`grep 22 $OUTPUT_FOLDER_BASE$1/$1_regular.gnmap | cut -f2 -d"/"`
if [ "$fine" == "open" ]; then
	test_ssh $1 22
fi

fine=`grep 25 $OUTPUT_FOLDER_BASE$1/$1_regular.gnmap | cut -f2 -d"/"`
if [ "$fine" == "open" ]; then
	test_smtp $1 25
fi

fine=`grep 53 $OUTPUT_FOLDER_BASE$1/$1_regular.gnmap | cut -f2 -d"/"`
if [ "$fine" == "open" ]; then
	test_dns $1 53
fi

fine=`grep 3306 $OUTPUT_FOLDER_BASE$1/$1_regular.gnmap | cut -f2 -d"/"`
if [ "$fine" == "open" ]; then
	test_mysql $1 3306
fi


fine=`grep 80 $OUTPUT_FOLDER_BASE$1/$1_regular.gnmap | cut -f2 -d"/"`
if [ "$fine" == "open" ]; then
	test_http $1 false 80
fi

fine=`grep 8080 $OUTPUT_FOLDER_BASE$1/$1_regular.gnmap | cut -f2 -d"/"`
if [ "$fine" == "open" ]; then
	test_http $1 false 8080 
fi

fine=`grep 433 $OUTPUT_FOLDER_BASE$1/$1_regular.gnmap | cut -f2 -d"/"`
if [ "$fine" == "open" ]; then
	test_http $1 true 433 
fi

fine=`grep 8443 $OUTPUT_FOLDER_BASE$1/$1_regular.gnmap | cut -f2 -d"/"`
if [ "$fine" == "open" ]; then
	test_http $1 true 8443
fi

fine=`grep 445 $OUTPUT_FOLDER_BASE$1/$1_regular.gnmap | cut -f2 -d"/"`
if [ "$fine" == "open" ]; then
  if [ -x $SMBCLIENT ]; then
    info "[*] launching smbclient"
    $SMBCLIENT -L $1 > $OUTPUT_FOLDER_BASE$1/$1.smbclient
  else
		fine=`grep 139 $OUTPUT_FOLDER_BASE$1/$1_regular.gnmap | cut -f2 -d"/"`
		if [ "$fine" == "open" ]; then
			if [ -x $SMBCLIENT ]; then
				info "[*] launching smbclient"
				$SMBCLIENT -L $1 > $OUTPUT_FOLDER_BASE$1/$1.smbclient
			else
				warning "[!] $APPNAME skipping smbclient"
			fi
		fi
  fi
fi

if [ ! -f $SAVEDIR/$1_full.nmap ]; then
  info "[*] launcing full scan"
  $NMAP -v0 -p- -sT $1 --reason -oA $SAVEDIR/$1_full
else
  warning "[!] $SAVEDIR/$1_full.nmap exists. Skipping scan"
fi

if [ ! -f $SAVEDIR/$1_udp.nmap ]; then
  info "[*] launcing UDP full scan"
  $NMAP -v0 -p- -sU $1 --reason -oA $SAVEDIR/$1_udp
else
  warning "[!] $SAVEDIR/$1_udp.nmap exists. Skipping scan"
fi


if [ -x $SEARCHSPLOIT ]; then
  SPLOIT_OUTPUT=$OUTPUT_FOLDER_BASE$1/$1_sploits
  rm -rf foo
  info "[*] looking for exploits"
  $SEARCHSPLOIT --nmap $OUTPUT_FOLDER_BASE$1/$1_full.xml > /dev/null 2> "foo"
  cat "foo" | sed 's/^... //' > $SPLOIT_OUTPUT
  info "[*] please check $SPLOIT_OUTPUT for available exploits"
  rm -rf foo
else
  warning "[!] $APPNAME skipping searchsploit"
fi

