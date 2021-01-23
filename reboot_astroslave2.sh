#!/bin/bash -eux
ssh astroslave2.local id
ssh astroslave2.local sudo reboot || true
sleep 1
for i in $(seq 120)
do
	sleep 1
	echo "Testing INDI servers round $i..."
	if ! ping -c1 -W1 astroslave2.local ; then continue ; fi
	if ! echo Alive? > /dev/tcp/astroslave2.local/7625 ; then continue ; fi
	if ! echo Alive? > /dev/tcp/astroslave2.local/7624 ; then continue ; fi
	break
done
echo "INDI servers are alive, delaying..."
sleep 10
echo "Testing statuses..."
ssh astroslave2.local lsusb
ssh astroslave2.local systemctl --user status indiserver_main.service
ssh astroslave2.local systemctl --user status indiserver_aux.service
echo "Complete."
