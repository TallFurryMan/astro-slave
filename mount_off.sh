stty -F /dev/ttyACM0 57600
echo Mount
echo "R21;" > /dev/ttyACM0
sleep 2
echo "R21;" > /dev/ttyACM0
sleep 2
