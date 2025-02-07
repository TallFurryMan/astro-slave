

DRV_MAIN:=indi_eqmod_telescope.service indi_simulator_wheel.service indi_atik_ccd.service indi_moonlite_focus.service indi_v4l2_ccd.service indi_zwo_efw.service
DRV_AUX:=indi_guider_ccd.service
SCK_MAIN:=indiserver_main.socket
SCK_AUX:=indiserver_aux.socket
SRV_MAIN:=indiserver_main.service
SRV_AUX:=indiserver_aux.service

SOCKETS:=$(SCK_MAIN) $(SCK_AUX)
SERVERS:=$(SRV_MAIN) $(SRV_AUX)
UNITS:=$(SOCKETS) $(SERVERS) $(DRV_MAIN) $(DRV_AUX)
UNITDIR:=~/.config/systemd/user

all: $(UNITS)

status=systemctl --user --no-pager -l status

install: stop all
	install -Dv -m=0644 --target-directory $(UNITDIR) $(UNITS)
	systemctl --user daemon-reload
	systemctl --user enable $(UNITS)
	systemctl --user restart $(SERVERS)
	-$(status) $(SOCKETS)
	-$(status) $(SERVERS)

install-vnc:
	sudo systemctl stop x0vncserver autocutsel
	if ! which x0vncserver >/dev/null ; then sudo apt-get install -y tigervnc-scraping-server autocutsel ; fi
	sudo install -Dv -m=0644 --target-directory /etc/systemd/system/ x0vncserver.service autocutsel.service
	sudo systemctl daemon-reload
	sudo systemctl enable --now x0vncserver autocutsel
	sudo systemctl status x0vncserver

install-phd2:
	install -Dv -m=0644 --target-directory $(UNITDIR) phd2.service
	systemctl --user daemon-reload
	systemctl --user disable phd2
	systemctl --user start phd2

install-kstars:
	install -Dv -m=0644 --target-directory $(UNITDIR) kstars.service
	systemctl --user daemon-reload
	systemctl --user disable kstars
	systemctl --user start kstars

start:
	-systemctl --user start $(SERVERS)
	$(status) $(SOCKETS)
	-$(status) $(SERVERS)

stop:
	-systemctl --user stop $(SERVERS)
	-$(status) $(SOCKETS)
	-$(status) $(SERVERS)

test-moonlite:
	@echo "======================= SETUP"
	-$(status) indi_moonlite_focus
	@echo "======================= REMOVING USB TTY"
	sudo udevadm trigger --action="remove" --name-match=/dev/ttyUSB1
	-$(status) indi_moonlite_focus
	sleep 5
	@echo "======================= ADDING USB TTY"
	sudo udevadm trigger --action="add" --name-match=/dev/ttyUSB1
	sleep 5
	@echo "======================= CHECKING"
	-$(status) indi_moonlite_focus
	-$(status) $(SRV_MAIN)
	@echo "======================= TEARDOWN"

test: start stop
