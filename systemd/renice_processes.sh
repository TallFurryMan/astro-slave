#!/bin/env bash

set -eu

while true
do

# More priority for indi eqmod
ps -el | grep [i]ndi_eqmod_tele | awk '{print$8,$4}' | while read -r pri pid ; do if [ $pri -gt -1 ] ; then sudo renice --priority -1 --pid $pid ; fi ; done
ps -el | grep [i]ndiserver | awk '{print$8,$4}' | while read -r pri pid ; do if [ $pri -gt -1 ] ; then sudo renice --priority -1 --pid $pid ; fi ; done

sleep 5
done
