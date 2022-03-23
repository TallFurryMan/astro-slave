#!/bin/bash
if [ -f .scope_heater_on ]
then
echo Nope
else
stty -F /dev/ttyACM0 57600
echo Heater
echo "R31;" > /dev/ttyACM0
sleep 2
echo "R31;" > /dev/ttyACM0
sleep 2
fi
