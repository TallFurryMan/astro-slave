#!/bin/env -S bash -eu
stty -F /dev/ttyACM0 57600
echo Accessory
echo "R41;" > /dev/ttyACM0
