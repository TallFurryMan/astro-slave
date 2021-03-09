#!/bin/bash -eu
stty -F /dev/ttyACM0 57600
./imager_on.sh
./guider_on.sh
echo Mount
echo "R20;" > /dev/ttyACM0
sleep 2
lsusb -tv | grep -iB1 067b:2303
