#!/usr/bin/env bash

function create_output_folder() {
  mkdir -p $1
  mkdir -p $1/scans
  mkdir -p $1/shots
  mkdir -p $1/sploits
  mkdir -p $1/flags
  touch $1/notes.txt
}

function find_sploits() {
if [ -x $SEARCHSPLOIT ]; then
  SPLOIT_OUTPUT=$2/$1_sploits
  info "looking for exploits"
  $SEARCHSPLOIT --nmap $2/$1_full.xml > /dev/null 2> "foo"
  cat "foo" | sed 's/^... //' > $SPLOIT_OUTPUT
  info "please check $SPLOIT_OUTPUT for available exploits"
  rm -rf foo
else
  warning "searchsploit not found. Skipping"
fi
}

# $1 port to be checked
function is_port_open() {

	case "$OSTYPE" in
		solaris*) echo "SOLARIS" ;;
		darwin*)  o=$(grep -oE '\d{1,5}/open' $greppable | grep $1) ;;
		linux*)   o=$(grep -oP '\d{1,5}/open' $greppable | grep $1) ;;
		bsd*)     echo "BSD" ;;
		msys*)    echo "WINDOWS" ;;
		*)        echo "unknown: $OSTYPE" ;;
	esac

	if [ "$o" == "" ]; then
		echo 0;
	else
		echo 1;
	fi

}

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



# TODO: big improvement here in the future. the grep must take care about basic
# services running on different ports (eg. ssh running on 2222)

# $1 - protocol
# $2 - IP
# $3 - gnmap file
# $4 - savedir
function launch_scan_if_open() {

  if [ "$1" == "ftp" ]; then
		o=$(is_port_open 21)
		if [ "$o" == "1" ]; then
      test_ftp $2 21 $4
    fi
  fi

  if [ "$1" == "ssh" ]; then
		o=$(is_port_open 22)
		if [ "$o" == "1" ]; then
      test_ssh $2 22 $4
    fi
  fi

  if [ "$1" == "smtp" ]; then
		o=$(is_port_open 25)
		if [ "$o" == "1" ]; then
      test_smtp $2 25 $4
    fi
  fi

  if [ "$1" == "dns" ]; then
		o=$(is_port_open 53)
		if [ "$o" == "1" ]; then
      test_dns $2 53 $4
    fi
  fi


  if [ "$1" == "smb" ]; then

		o=$(is_port_open 445)
		if [ "$o" == "1" ]; then
      test_smb $2 445 $4
    else
			o=$(is_port_open 139)
			if [ "$o" == "1" ]; then
				test_smb $2 139 $4
			fi
    fi
  fi

  if [ "$1" == "mysql" ]; then
		o=$(is_port_open 3306)
		if [ "$o" == "1" ]; then
      test_mysql $1 3306 $4
    fi
  fi

  # TODO: a better approach must be done to define a single portlist
  if [ "$1" == "web" ]; then
		o=$(is_port_open 80)
		if [ "$o" == "1" ]; then
      test_http $1 false 80 $4
    fi

		o=$(is_port_open 8080)
		if [ "$o" == "1" ]; then
      test_http $1 false 8080  $4
    fi

		o=$(is_port_open 443)
		if [ "$o" == "1" ]; then
      test_http $1 true 443  $4
    fi

		o=$(is_port_open 8443)
		if [ "$o" == "1" ]; then
      test_http $1 true 8443 $4
    fi
  fi
}
