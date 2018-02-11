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





args=`getopt hvi: $*`
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
    -i)
      target="$2"; shift;
      shift;;
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

info "$APPNAME is recon $target. Saving results in $SAVEDIR"
create_output_folder $SAVEDIR

basic_portscan $target $SAVEDIR
ports=$(open_port_list $SAVEDIR/scans/$target_regular.gnmap)
info "Interesting TCP ports found $ports"


launch_scan_if_open "ftp" $target $SAVEDIR/scans/$target_regular.gnmap $SAVEDIR/scans
launch_scan_if_open "ssh" $target $SAVEDIR/scans/$target_regular.gnmap $SAVEDIR/scans
launch_scan_if_open "smtp" $target $SAVEDIR/scans/$target_regular.gnmap $SAVEDIR/scans
launch_scan_if_open "dns" $target $SAVEDIR/scans/$target_regular.gnmap $SAVEDIR/scans
launch_scan_if_open "mysql" $target $SAVEDIR/scans/$target_regular.gnmap $SAVEDIR/scans
launch_scan_if_open "web" $target $SAVEDIR/scans/$target_regular.gnmap $SAVEDIR/scans
launch_scan_if_open "smb" $target $SAVEDIR/scans/$target_regular.gnmap $SAVEDIR/scans

full_portscan $target $SAVEDIR
find_sploits $target $SAVEDIR

udp_portscan $target $SAVEDIR

info "Bye."

