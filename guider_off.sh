#!/bin/bash -eu
systemctl --user stop phd2
stty -F /dev/ttyACM0 57600
echo Secondary camera
echo "R11;" > /dev/ttyACM0
sleep 2
echo "R11;" > /dev/ttyACM0
sleep 2
lsusb -tv | grep -iB1 04b4:df2d
