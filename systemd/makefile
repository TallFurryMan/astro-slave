

DRIVERS:=indi_eqmod_telescope@.service indi_v4l2_ccd@.service indi_simulator_wheel@.service indi_atik_ccd@.service 
SERVERS:=indiserver@.socket indiserver@.service 
UNITS:=$(SERVERS) $(DRIVERS)
#UNITDIR:=$(shell pkg-config systemd --variable=systemdsystemconfdir)
UNITDIR:=~/.config/systemd/user

INS_DRIVERS:=$(foreach d,$(DRIVERS),$(subst @,@7624,$d))

all: $(UNITS)

SCK7624:=indiserver@7624.socket
SRV7624:=indiserver@7624.service
SCK7625:=indiserver@7625.socket
SRV7625:=indiserver@7625.service

install: all
	install -Dv -m=0644 --target-directory $(UNITDIR) $(UNITS)
	systemctl --user daemon-reload
	systemctl --user enable $(SCK7624) $(SRV7624) $(SCK7625) $(SRV7625)
	systemctl --user restart $(SCK7624) $(SCK7625)
	systemctl --user --no-pager status $(SCK7624) $(SCK7625)
	-systemctl --user --no-pager status $(SRV7624) $(SRV7625)

install-vnc:
	sudo apt-get install -y tigervnc-standalone-server
	sudo install -Dv -m=0644 --target-directory /etc/systemd/system/ x0vncserver.service
	sudo systemctl enable x0vncserver
	sudo systemctl start x0vncserver

start:
	if ! systemctl --user is-active $(SCK7624) ; then echo "Activating indiserver socket..." ; systemctl --user restart $(SCK7624) ; fi
	systemctl --user --no-pager status $(SCK7624)
	-systemctl --user --no-pager status $(SRV7624)

stop:
	if systemctl --user is-active $(SCK7624) ; then systemctl --user stop $(SCK7624) ; fi
	-systemctl --user --no-pager status $(SCK7624)
	-systemctl --user --no-pager status $(SRV7624)

run-test:
	systemctl --user --no-pager start $(INS_DRIVERS)
	-systemctl --user --no-pager status $(INS_DRIVERS)

test: start run-test stop
