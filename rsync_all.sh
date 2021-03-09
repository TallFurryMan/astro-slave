#!/bin/bash -eux
./rsync_IC434_Mosaic.sh &
./rsync_M101.sh &
./rsync_M42.sh &
./rsync_M45.sh &
./rsync_Flats.sh &
./rsync_IC443.sh &
./rsync_NGC2238.sh &
./rsync_NGC4443_Mosaic.sh &
while true ; do sleep 5; done
