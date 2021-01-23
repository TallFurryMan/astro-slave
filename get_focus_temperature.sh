#!/bin/bash -eux
python3 ./testindiclient.py | grep -A2 'FOCUS_TEMPERATURE' | grep ' TEMPERATURE' | cut -d= -f2
