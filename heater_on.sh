stty -F /dev/ttyACM0 57600
echo Heater
[ "$1" = "force" ] && touch .scope_heater_on
echo "R30;" > /dev/ttyACM0
sleep 2
echo "R30;" > /dev/ttyACM0
sleep 2
