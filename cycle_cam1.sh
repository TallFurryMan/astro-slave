stty -F /dev/ttyACM0 57600
echo "R01;" > /dev/ttyACM0
lsusb -tv
sleep 5
echo "R00;" > /dev/ttyACM0
lsusb -tv
