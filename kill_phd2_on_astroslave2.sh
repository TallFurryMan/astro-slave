#!/bin/bash -eux
ssh astroslave2.local id
echo "Slave is alive, shutting PHD2 down..."
ssh astroslave2.local ps -aef | grep phd2
ssh astroslave2.local killall --wait phd2.bin
echo "Waiting for PHD2 to restart..."
sleep 5
ssh astroslave2.local ps -aef | grep phd2
echo "Complete."
