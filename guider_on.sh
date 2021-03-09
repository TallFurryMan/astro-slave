#!/bin/bash -eu
stty -F /dev/ttyACM0 57600
echo Secondary camera
echo "R10;" > /dev/ttyACM0
sleep 2
lsusb -tv | grep -iB1 04b4:df2d
