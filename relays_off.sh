#!/bin/bash -eu
systemctl --user stop phd2
stty -F /dev/ttyACM0 57600
echo Relays
echo "R01;R11;R21;R31;R41;" > /dev/ttyACM0
sleep 2
echo "R01;R11;R21;R31;R41;" > /dev/ttyACM0
sleep 2
