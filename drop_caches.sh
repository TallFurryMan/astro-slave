#!/bin/bash -eu
while true
do
	echo "----- $(date)"
	top -bn1 | head -4
	sync
	echo 3 | sudo tee /proc/sys/vm/drop_caches
	top -bn1 | head -4
	sleep 30
done
