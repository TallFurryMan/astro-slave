#!/bin/bash -eu
stty -F /dev/ttyACM0 57600
./imager_on.sh
./guider_on.sh
./mount_on.sh
touch .scope_heater_on
./heater_on.sh
systemctl --user start phd2
