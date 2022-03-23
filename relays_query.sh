#!/bin/bash -eu
stty -F /dev/ttyACM0 57600
#exec 3</dev/ttyACM0
tail -f /dev/ttyACM0 &
pid=$!
sleep 1
printf "R?\n" >/dev/ttyACM0
#while read -t 1 answer </dev/ttyACM0 ; do echo "${answer:2}" ; done
#exec 3<&-
sleep 2
kill $pid
