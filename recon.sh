#!/usr/bin/env bash
#
# recon.sh - reconnaissance script for first stage of a penetration test
# 
# Made with love, vim and shell by thesp0nge - paolo@codiceinsicuro.it
#
# Changelog
# 

. stdio.sh
. aux_tools.sh
. stdlib.sh
. portscan.sh
. base_daemon_tests.sh
. web.sh

args=`getopt hvi:p:P: $*`
if [ $? != 0 ]
then
  usage
  exit 2
fi
set -- $args
for i
do
  case "$i"
    in
    -v)
      version
      exit 3
      ;;
    -h)
      usage
      exit 3
      ;;
		-p)
			port="$2"; shift; shift;
			;;
		-P)
			proto="$2"; shift; shift;
			;;
    -i)
      target="$2"; shift;shift;
			;;
    --)
    shift; break;;
  esac
done

if [ $UID -ne 0 -a $EUID -ne 0 ]; then
  error "this script must be executed as root"
#  exit 1
fi

if [ -z $target ]; then
  error "missing target"
  usage
  exit 1
fi

# Be polite. Say hello. It starts from here.
greeting

# Without nmap there is no way to go further.
test_and_exit_if_not_found $NMAP


declare SAVEDIR=$OUTPUT_FOLDER_BASE$target

log "recon $target" 
log "saving results in $SAVEDIR"
create_output_folder $SAVEDIR

if [ -z $port ]; then
	basic_portscan $target $SAVEDIR
	greppable="$SAVEDIR/scans/$target""_regular.gnmap"
	ports=$(open_port_list $greppable)
	log "Interesting TCP ports found $ports"

else
	basic_portscan_for_a_given_port $target $SAVEDIR $port
	greppable="$SAVEDIR/scans/$target""_regular_on_port_$port.gnmap"
fi

if [ -z $proto ]; then
	launch_scan_if_open "ftp" $target $greppable $SAVEDIR/scans $port
	launch_scan_if_open "ssh" $target $greppable $SAVEDIR/scans $port
	launch_scan_if_open "smtp" $target $greppable $SAVEDIR/scans $port
	launch_scan_if_open "dns" $target $greppable $SAVEDIR/scans $port
	launch_scan_if_open "mysql" $target $greppable $SAVEDIR/scans $port
	launch_scan_if_open "web" $target $greppable $SAVEDIR/scans $port
	launch_scan_if_open "smb" $target $greppable $SAVEDIR/scans $port
else
	launch_scan_if_open $proto $target $greppable $SAVEDIR/scans $port

fi

full_portscan $target $SAVEDIR
find_sploits $target $SAVEDIR

udp_portscan $target $SAVEDIR

log "Bye."

