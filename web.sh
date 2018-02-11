#!/usr/bin/env bash

# $1 - IP
# $2 - true/false -> ssl?
# $3 - port
# $4 - target dir



function test_http {


	if [ -z $2 ]; then
		secure=false
	else
		secure=$2
	fi

	if [ -z $3 ]; then
		if [ $secure == "false" ]; then
			port=80
		fi
		if [ $secure == "true" ]; then
			port=443
		fi
	else
		port=$3
	fi

  info "scanning HTTP/HTTPS on port $3"

  if [ -x $DIRB ]; then
		if [ ! -f $4/$1_$port.dirb ]; then
			info "launching dirb"
			if [ $secure == "false" ]; then
				$DIRB http://$1:$port -S -o $4/$1_$port.dirb 2> /dev/null > /dev/null
			fi
			if [ $secure == "true" ]; then
				$DIRB https://$1:$port -S -o $4/$1_$port.dirb 2> /dev/null > /dev/null
			fi
		else
			warning "$4/$1_$port.dirb exists. Skipping scan"
		fi
  else
    warning "dirb is not installed. Skipping scan"
  fi

  if [ -x $NIKTO ]; then
    if [ ! -f $4/$1_$port.nikto ]; then
      info "launching nikto"
      if [ $secure == "false" ]; then
        $NIKTO -host http://$1 -port $port -Format txt -output $4/$1_$port.nikto  2> /dev/null > /dev/null
      fi
      if [ $secure == "true" ]; then
        $NIKTO -host https://$1 -ssl -port $port -Format txt -output $4/$1_$port.nikto  2> /dev/null > /dev/null
      fi
    else
      warning "$4/$1_$port.nikto exists. Skipping scan"
    fi
  else
    warning "nikto is not installed. Skipping scan"
  fi

	warning "you may want to manual launch $WFUZZ against $1"
	warning "if DAV enabled you may want to launch $DAVTEST -url $1"

	if [ $secure == "true" ]; then 
		fetch_http_web_root $1 $port $4
	else
		fetch_https_web_root $1 $port $4
	fi


	whatweb_web $1 $secure $4

	if [ -x $SQLMAP ]; then
		info "launching sqlmap"
		$SQLMAP -u http://$1 --crawl=3 --output-dir=$4 --batch
	fi

}

function whatweb_web {
  if [ ! -x $WHATWEB ]; then
    warning "whatweb not installed. Skipping tests"
  else

    info "launching whatweb on $1"
    if [ $2 == "false" ]; then
      $WHATWEB -v http://$1 > $3/$1.whatweb
    fi
    if [ $2 == "true" ]; then
      $WHATWEB -v https://$1 > $3/$1.whatweb
    fi

  fi
}

function fetch_http_web_root {
  info "[*] fetching website root on $1 (port $2)" 
  $CURL -i -L http://$1:$2 > $3/$1_$2.curl
}

function fetch_https_web_root {
  info "[*] fetching website root on $1 (port $2) - HTTPS" 
  $CURL -i -L https://$1:$2
	$NMAP -sV -p $port --script=ssl-heartbleed.nse $1 -oA $4/$1_$port_hearbleed
}


