#!/bin/bash -eu
stty -F /dev/ttyACM0 57600
echo Primary camera
echo "R00;" > /dev/ttyACM0
sleep 2
timeout 7s indiserver indi_atik_ccd || true
lsusb -tv | grep -iB1 20e7:dfc3 
