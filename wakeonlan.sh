#!/bin/bash -eux

# Arhiman
# MAC=E0:D5:5E:E2:8E:57

# AstroSlave
#MAC=00:01:c0:08:20:25

# AstroMaster
MAC=00:01:c0:06:2d:25
IP=192.168.1.192

# Main Wifi
# Broadcast=192.168.0.255

# Observatory
Broadcast=192.168.1.255

while ! ping -I enx00e04c3605a6 -c5 $IP
do

if which ncat >/dev/null
then
	PortNumber=9
	echo -e     \xff\xff\xff\xff\xff\xff |     ncat -w1 -u  
elif which wakeonlan >/dev/null
then
	wakeonlan $MAC
	wakeonlan -i $Broadcast $MAC
else
	echo Nope. >&2
fi

sleep 5
done
