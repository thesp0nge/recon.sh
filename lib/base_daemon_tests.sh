#!/usr/bin/env bash

# $1 - IP
# $2 - port
# $3 - target dir

function test_ftp {
	info "scanning FTP service on port $2"
	if [ -z $2 ]; then
		port=21
	else
		port=$2
	fi

	$NMAP -v0 -sT -p $port --script="ftp-anon.nse,ftp-bounce.nse,ftp-brute.nse,ftp-libopie.nse,ftp-proftpd-backdoor.nse,ftp-vsftpd-backdoor.nse,ftp-vuln-cve2010-4221.nse,tftp-enum.nse" $1 -oA $3/$1_ftp
}

# $1 - IP
# $2 - port
# $3 - target dir

function test_ssh {
  info "scanning SSH service on port $2"
  if [ -z $2 ]; then
    port=22
  else
    port=$2
  fi

  $NMAP -v0 -sT -p $port --script="ssh2-enum-algos.nse,ssh-hostkey.nse,sshv1.nse" $1 -oA $3/$1_ssh
}


function test_smtp {
  info "scanning SMTP service on port $2"
	if [ -z $2 ]; then
		port=25
	else
		port=$2
	fi

	$NMAP -v0 -sT -p $port --script="smtp-brute.nse,smtp-commands.nse,smtp-enum-users.nse,smtp-ntlm-info.nse,smtp-open-relay.nse,smtp-strangeport.nse,smtp-vuln-cve2010-4344.nse,smtp-vuln-cve2011-1720.nse,smtp-vuln-cve2011-1764.nse" $1 -oA $3/$1_smtp
}

function test_dns {
	info "scanning DNS service on port $2"
	if [ -z $2 ]; then
		port=53
	else
		port=$2
	fi

	$NMAP -v0 -sT -p $port --script="broadcast-dns-service-discovery.nse,dns-blacklist.nse,dns-brute.nse,dns-cache-snoop.nse,dns-check-zone.nse,dns-client-subnet-scan.nse,dns-fuzz.nse,dns-ip6-arpa-scan.nse,dns-nsec3-enum.nse,dns-nsec-enum.nse,dns-nsid.nse,dns-random-srcport.nse,dns-random-txid.nse,dns-recursion.nse,dns-service-discovery.nse,dns-srv-enum.nse,dns-update.nse,dns-zeustracker.nse,dns-zone-transfer.nse,fcrdns.nse" $1 -oA $3/$1_dns
}

function test_smb() {
  info "scanning SMB service on port $2"
  if [ ! -x $SMBCLIENT ]; then
    warning "sambaclient non installed. Skipping tests"
  else
    $SMBCLIENT -L $1 > $3/$1_smbclient
  fi
}

function test_mysql {
	info "scanning MYSQL service on port $2"
	if [ -z $2 ]; then
		port=3306
	else
		port=$2
	fi

	$NMAP -v0 -sT -p $port --script="mysql-audit.nse,mysql-brute.nse,mysql-databases.nse,mysql-dump-hashes.nse,mysql-empty-password.nse,mysql-enum.nse,mysql-info.nse,mysql-query.nse,mysql-users.nse,mysql-variables.nse,mysql-vuln-cve2012-2122.nse" $1 -oA $3/$1_mysql
}

