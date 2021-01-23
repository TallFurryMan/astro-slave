#!/bin/bash -eux

# Arhiman
# MAC=${1:-E0:D5:5E:E2:8E:57}

# AstroSlave
MAC=${1:-00:01:c0:08:20:25}

# Main Wifi
# Broadcast=192.168.0.255

# Observatory
Broadcast=192.168.1.255


PortNumber=9

echo -e \
    $(echo \
        $(printf 'f%.0s' {1..12}; printf "$(echo $MAC | sed 's/://g')%.0s" {1..16}) | \
        sed -e 's/../\\x&/g') | \
    ncat -w1 -u $Broadcast $PortNumber
