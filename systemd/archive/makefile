

DRV_MAIN:=indi_eqmod_telescope@.service indi_simulator_wheel@.service indi_atik_ccd@.service indi_moonlite_focus@.service
DRV_AUX:=indi_v4l2_ccd@.service
SERVERS:=indiserver@.socket indiserver@.service 
UNITS:=$(SERVERS) $(DRV_MAIN) $(DRV_AUX)
UNITDIR:=~/.config/systemd/user

INS_DRIVERS:=$(foreach d,$(DRIVERS),$(subst @,@7624,$d))

all: $(UNITS)

SCK7624:=indiserver@7624.socket
SRV7624:=indiserver@7624.service
SCK7625:=indiserver@7625.socket
SRV7625:=indiserver@7625.service
DRV7624:=$(foreach d,$(DRV_MAIN),$(subst @,@7624,$d))
DRV7625:=$(foreach d,$(DRV_AUX),$(subst @,@7625,$d))

status=systemctl --user --no-pager -l status

install: all
	install -Dv -m=0644 --target-directory $(UNITDIR) $(UNITS)
	systemctl --user daemon-reload
	systemctl --user enable $(SCK7624) $(SRV7624) $(SCK7625) $(SRV7625) $(DRV7624) $(DRV7625)
	systemctl --user restart $(SCK7624) $(SCK7625)
	$(status) $(SCK7624) $(SCK7625)
	-$(status) $(SRV7624) $(SRV7625)
	-$(status) $(DRV7624) $(DRV7625)

install-vnc:
	sudo apt-get install -y tigervnc-standalone-server
	sudo install -Dv -m=0644 --target-directory /etc/systemd/system/ x0vncserver.service
	sudo systemctl enable x0vncserver
	sudo systemctl start x0vncserver

start:
	if ! systemctl --user is-active $(SCK7624) ; then echo "Activating indiserver socket..." ; systemctl --user restart $(SCK7624) ; fi
	$(status) $(SCK7624)
	-$(status) $(SRV7624)

stop:
	if systemctl --user is-active $(SCK7624) ; then systemctl --user stop $(SCK7624) ; fi
	-$(status) $(SCK7624)
	-$(status) $(SRV7624)

test-moonlite:
	@echo "======================= SETUP"
	-$(status) indi_moonlite_focus@7624
	@echo "======================= REMOVING USB TTY"
	sudo udevadm trigger --action="remove" --name-match=/dev/ttyUSB1
	-$(status) indi_moonlite_focus@7624
	sleep 5
	@echo "======================= ADDING USB TTY"
	sudo udevadm trigger --action="add" --name-match=/dev/ttyUSB1
	sleep 5
	@echo "======================= CHECKING"
	-$(status) indi_moonlite_focus@7624
	-$(status) indiserver@7624.server
	@echo "======================= TEARDOWN"

test: start run-test stop
