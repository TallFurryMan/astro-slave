#! /bin/bash -eux
python -c 'import pyfirmata ; b = pyfirmata.Arduino("/dev/ttyACM0") ; b.digital[7].write(1) ; b.digital[8].write(1) ; b.digital[12].write(1)'
