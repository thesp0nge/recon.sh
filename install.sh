#!/usr/bin/env bash

INSTALL=`which install`
TARGET="/usr/local/share/recon.sh"

if [ ! -x $INSTALL ]; then
	echo "Can't find install binary."
	exit 1
fi

$INSTALL -d $TARGET
$INSTALL -d $TARGET/lib

$INSTALL -D CHANGELOG.md -m 444 $TARGET
$INSTALL -D LICENSE -m 444 $TARGET
$INSTALL -D README.md -m 444 $TARGET

$INSTALL -D lib/aux_tools.sh -m 444 $TARGET/lib
$INSTALL -D lib/base_daemon_tests.sh -m 444 $TARGET/lib
$INSTALL -D lib/portscan.sh -m 444 $TARGET/lib
$INSTALL -D lib/stdio.sh -m 444 $TARGET/lib
$INSTALL -D lib/stdlib.sh -m 444 $TARGET/lib
$INSTALL -D lib/web.sh -m 444 $TARGET/lib

$INSTALL -D recon.sh -m 755 $TARGET
ln -sf $TARGET/recon.sh /usr/local/sbin

echo "recon.sh package installed in $TARGET"
echo "recon.sh binary file installed in /usr/local/sbin."
echo "Make sure to add /usr/local/sbin to your PATH."
echo
echo "Enjoy!"

