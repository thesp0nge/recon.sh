#!/bin/bash
# recon.sh - reconnaissance script for first stage of a penetration test
# 
# Made with love, vim and shell by thesp0nge - paolo@codiceinsicuro.it
#
# Changelog
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

function whatweb_web {
	echo "[*] launching webweb on $1"
	$WHATWEB -v $1 > $OUTPUT_FOLDER_BASE$1/$1_whatweb
}
function fetch_http_web_root {
  if [ -z $2 ]; then
    port = 80
  else
    port = $2
  fi
  echo "[*] fetching website root on $1 (port $port)" 
  $CURL -i -L http://$1 
}

function fetch_https_web_root {
  if [ -z $2 ]; then
    port = 443
  else
    port = $2
  fi
  echo "[*] fetching website root on $1 (port $port) - HTTPS" 
  $CURL -i -L https://$1 
	$NMAP -sV -p $port --script=ssl-heartbleed.nse $1 -oA $OUTPUT_FOLDER_BASE$1/$1_$port_hearbleed
}


function test_ftp {
	echo "[*] scanning FTP service"
	if [ -z $2 ]; then
		echo "[!] defaulting to FTP port 21"
		port=21
	else
		port=$2
	fi

	$NMAP -v0 -sT -p $port --script="ftp-anon.nse,ftp-bounce.nse,ftp-brute.nse,ftp-libopie.nse,ftp-proftpd-backdoor.nse,ftp-vsftpd-backdoor.nse,ftp-vuln-cve2010-4221.nse,tftp-enum.nse" $1 -oA $OUTPUT_FOLDER_BASE$1/$1_ftp
}

function test_ssh {
	echo "[*] scanning SSH service"
	if [ -z $2 ]; then
		echo "[!] defaulting to SSH port 22"
		port=22
	else
		port=$2
	fi

	$NMAP -v0 -sT -p $port --script="ssh2-enum-algos.nse,ssh-hostkey.nse,sshv1.nse" $1 -oA $OUTPUT_FOLDER_BASE$1/$1_ssh
}


function test_smtp {
	echo "[*] scanning SMTP service"
	if [ -z $2 ]; then
		echo "[!] defaulting to SMTP port 25"
		port=25
	else
		port=$2
	fi

	$NMAP -v0 -sT -p $port --script="smtp-brute.nse,smtp-commands.nse,smtp-enum-users.nse,smtp-ntlm-info.nse,smtp-open-relay.nse,smtp-strangeport.nse,smtp-vuln-cve2010-4344.nse,smtp-vuln-cve2011-1720.nse,smtp-vuln-cve2011-1764.nse" $1 -oA $OUTPUT_FOLDER_BASE$1/$1_smtp
}

function test_dns {
	echo "[*] scanning DNS service"
	if [ -z $2 ]; then
		echo "[!] defaulting to DNS port 53"
		port=53
	else
		port=$2
	fi

	$NMAP -v0 -sT -p $port --script="broadcast-dns-service-discovery.nse,dns-blacklist.nse,dns-brute.nse,dns-cache-snoop.nse,dns-check-zone.nse,dns-client-subnet-scan.nse,dns-fuzz.nse,dns-ip6-arpa-scan.nse,dns-nsec3-enum.nse,dns-nsec-enum.nse,dns-nsid.nse,dns-random-srcport.nse,dns-random-txid.nse,dns-recursion.nse,dns-service-discovery.nse,dns-srv-enum.nse,dns-update.nse,dns-zeustracker.nse,dns-zone-transfer.nse,fcrdns.nse" $1  -oA $OUTPUT_FOLDER_BASE$1/$1_dns
}

function test_mysql {
	echo "[*] scanning MYSQL service"
	if [ -z $2 ]; then
		echo "[!] defaulting to MYSQL port 3306"
		port=3306
	else
		port=$2
	fi

	$NMAP -v0 -sT -p $port --script="mysql-audit.nse,mysql-brute.nse,mysql-databases.nse,mysql-dump-hashes.nse,mysql-empty-password.nse,mysql-enum.nse,mysql-info.nse,mysql-query.nse,mysql-users.nse,mysql-variables.nse,mysql-vuln-cve2012-2122.nse" $1  -oA $OUTPUT_FOLDER_BASE$1/$1_mysql
}



function test_http {
	if [ -z $2 ]; then
		echo "[!] defaulting to HTTP website"
		secure=false
	else
		secure=$2
	fi

	if [ -z $3 ]; then
		if [ $secure == "false" ]; then
			echo "[!] defaulting to port 80"
			port=80
		fi
		if [ $secure == "true" ]; then
			echo "[!] defaulting to port 443"
			port=443
		fi
	else
		port=$3
	fi

  if [ -x $DIRB ]; then
		if [ ! -f $OUTPUT_FOLDER_BASE$1/$1_$port.dirb ]; then
			echo "[*] launching dirb"
			if [ $secure == "false" ]; then
				$DIRB http://$1:$port -S -o $OUTPUT_FOLDER_BASE$1/$1_$port.dirb 2> /dev/null > /dev/null
			fi
			if [ $secure == "true" ]; then
				$DIRB https://$1:$port -S -o $OUTPUT_FOLDER_BASE$1/$1_$port.dirb 2> /dev/null > /dev/null
			fi
		else
			echo "[!] $OUTPUT_FOLDER_BASE$1/$1_$port.dirb exists. Skipping scan"
		fi
  else
    echo "[!] $APPNAME skipping dirb"
  fi

	if [ -x $NIKTO ]; then
		if [ ! -f $OUTPUT_FOLDER_BASE$1/$1_$port.nikto ]; then
			echo "[*] launching nikto"
			if [ $secure == "false" ]; then
				$NIKTO -host http://$1 -port $port -Format txt -output $OUTPUT_FOLDER_BASE$1/$1_$port.nikto  2> /dev/null > /dev/null
			fi
			if [ $secure == "true" ]; then
				$NIKTO -host https://$1 -ssl -port $port -Format txt -output $OUTPUT_FOLDER_BASE$1/$1_$port.nikto  2> /dev/null > /dev/null
			fi
	else
			echo "[!] $OUTPUT_FOLDER_BASE$1/$1_$port.nikto exists. Skipping scan"
	fi
  else
    echo "[!] $APPNAME skipping nikto"
  fi

	echo "[+] you may want to manual launch $WFUZZ against $1"
	echo "[+] if DAV enabled you may want to launch $DAVTEST -url $1"

	if [ $secure == "true" ]; then 
		fetch_http_web_root
	else
		fetch_https_web_root
	fi

	whatweb_web

	if [ -x $SQLMAP ]; then
		echo "[*] launching sqlmap"
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

# SQLMAP=`which sqlmap`
SQLMAP="/0"


APPNAME=`basename $0`
VERSION="0.8"
OUTPUT_FOLDER_BASE=./

# Without nmap there is no way to go further.
if [ ! -x $NMAP ]; then
  echo "$APPNAME: can't find nmap executable"
  exit 1
fi

if [ "$#" -ne 1 ]; then
  echo "$APPNAME: missing target"
  echo "usage: $APPNAME: ip_address"
  exit 1
fi

SAVEDIR=$OUTPUT_FOLDER_BASE$1
echo "[*] $APPNAME is recon $1. Saving results in $SAVEDIR"
mkdir -p $SAVEDIR
touch $SAVEDIR/notes.txt

if [ ! -f $SAVEDIR/$1_regular.nmap ]; then
  echo "[*] launcing regular scan"
  $NMAP -sC -sV -v0 -A -T4 $1 --reason -oA $SAVEDIR/$1_regular
else
  echo "[!] $SAVEDIR/$1_regular.nmap exists. Skipping scan"
fi


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
    echo "[*] launching smbclient"
    $SMBCLIENT -L $1 > $OUTPUT_FOLDER_BASE$1/$1.smbclient
  else
		fine=`grep 139 $OUTPUT_FOLDER_BASE$1/$1_regular.gnmap | cut -f2 -d"/"`
		if [ "$fine" == "open" ]; then
			if [ -x $SMBCLIENT ]; then
				echo "[*] launching smbclient"
				$SMBCLIENT -L $1 > $OUTPUT_FOLDER_BASE$1/$1.smbclient
			else
				echo "[!] $APPNAME skipping smbclient"
			fi
		fi
  fi
fi

if [ ! -f $SAVEDIR/$1_full.nmap ]; then
  echo "[*] launcing full scan"
  $NMAP -v0 -p- -sT $1 --reason -oA $SAVEDIR/$1_full
else
  echo "[!] $SAVEDIR/$1_full.nmap exists. Skipping scan"
fi

if [ ! -f $SAVEDIR/$1_udp.nmap ]; then
  echo "[*] launcing UDP full scan"
  $NMAP -v0 -p- -sU $1 --reason -oA $SAVEDIR/$1_udp
else
  echo "[!] $SAVEDIR/$1_udp.nmap exists. Skipping scan"
fi


if [ -x $SEARCHSPLOIT ]; then
  SPLOIT_OUTPUT=$OUTPUT_FOLDER_BASE$1/$1_sploits
  rm -rf foo
  echo "[*] looking for exploits"
  $SEARCHSPLOIT --nmap $OUTPUT_FOLDER_BASE$1/$1_full.xml > /dev/null 2> "foo"
  cat "foo" | sed 's/^... //' > $SPLOIT_OUTPUT
  echo "[+] please check $SPLOIT_OUTPUT for available exploits"
  rm -rf foo
else
  echo "[!] $APPNAME skipping searchsploit"
fi

