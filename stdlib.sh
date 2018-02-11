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
  if [ $1 -eq "ftp" ]; then
    fine=`grep 21 $3 | cut -f2 -d"/"`
    if [ "$fine" == "open" ]; then
      test_ftp $2 21 $4
    fi
  fi

  if [ $1 -eq "ssh" ]; then
    fine=`grep 22 $3 | cut -f2 -d"/"`
    if [ "$fine" == "open" ]; then
      test_ssh $2 22 $4
    fi
  fi

  if [ $1 -eq "smtp" ]; then
    fine=`grep 25 $3 | cut -f2 -d"/"`
    if [ "$fine" == "open" ]; then
      test_smtp $2 25 $4
    fi
  fi

  if [ $1 -eq "dns" ]; then
    fine=`grep 53 $3 | cut -f2 -d"/"`
    if [ "$fine" == "open" ]; then
      test_dns $2 53 $4
    fi
  fi


  if [ $1 -eq "smb" ]; then

    fine=`grep 445 $3 | cut -f2 -d"/"`
    if [ "$fine" == "open" ]; then
      test_smb $2 445 $4
    else
      fine=`grep 139 $3/$1_regular.gnmap | cut -f2 -d"/"`
      if [ "$fine" == "open" ]; then
        test_smb $2 139 $4
      fi
    fi
  fi


  if [ $1 -eq "mysql" ]; then

    fine=`grep 3306 $3 | cut -f2 -d"/"`
    if [ "$fine" == "open" ]; then
      test_mysql $1 3306 $4
    fi
  fi

  # TODO: a better approach must be done to define a single portlist
  if [ $1 -eq "web" ]; then
    fine=`grep 80 $3/$1_regular.gnmap | cut -f2 -d"/"`
    if [ "$fine" == "open" ]; then
      test_http $1 false 80 $4
    fi

    fine=`grep 8080 $3/$1_regular.gnmap | cut -f2 -d"/"`
    if [ "$fine" == "open" ]; then
      test_http $1 false 8080  $4
    fi

    fine=`grep 433 $3/$1_regular.gnmap | cut -f2 -d"/"`
    if [ "$fine" == "open" ]; then
      test_http $1 true 433  $4
    fi

    fine=`grep 8443 $3/$1_regular.gnmap | cut -f2 -d"/"`
    if [ "$fine" == "open" ]; then
      test_http $1 true 8443 $4
    fi

  fi

}
