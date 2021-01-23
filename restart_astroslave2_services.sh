#!/bin/bash -eux
ssh astroslave2.local id
echo "Restarting services..."
ssh astroslave2.local systemctl --user restart indiserver_main.service
ssh astroslave2.local systemctl --user restart indiserver_aux.service
sleep 5
echo "Testing statuses..."
ssh astroslave2.local lsusb
ssh astroslave2.local systemctl --user status indiserver_main.service
ssh astroslave2.local systemctl --user status indiserver_aux.service
echo "Complete."
