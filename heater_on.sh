stty -F /dev/ttyACM0 57600
echo Heater
echo "R30;" > /dev/ttyACM0
