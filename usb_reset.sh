#!/bin/bash -eu

echo "USB devices before reset:"
lsusb

[ -z "${1:-}" ] && exit 0

sudo id

if [ "${1:-}" = "uhci" ]
then
	for i in /sys/bus/pci/drivers/uhci_hcd/*:*
	do
		[ -e "$i" ] || continue
		echo "Resetting UHCI device '$i'..."
		echo "writing '${i##*/}' to '${i%/*}' unbind and bind"
		echo "${i##*/}" | sudo tee "${i%/*}/unbind"
		sleep 3
		echo "USB devices during reset:"
		lsusb
		echo "${i##*/}" | sudo tee "${i%/*}/bind'"
	done
fi

if [ "${1:-}" = "ehci" ]
then
	for i in /sys/bus/pci/drivers/ehci-pci/*:*
	do
		[ -e "$i" ] || continue
		echo "Resetting EHCI device '$i'..."
		echo "writing '${i##*/}' to '${i%/*}' unbind and bind"
		echo "${i##*/}" | sudo tee "${i%/*}/unbind"
		sleep 3
		echo "USB devices during reset:"
		lsusb
		echo "${i##*/}" | sudo tee "${i%/*}/bind"
	done
fi

echo "Waiting..."
sleep 5

echo "USB devices after reset:"
lsusb
