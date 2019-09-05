all:


install:
	sudo install -v -m=0644 * /etc/udev/rules.d
	sudo udevadm control -R
	sudo udevadm trigger
