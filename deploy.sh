#!/bin/bash -eux

DO_INSTALL=${DO_INSTALL:-nope}
DO_INDEXES=${DO_INDEXES:-nope}

# -------------

if false
then
	atik="atikccd-1.30-i386.deb"
	if ! ls -al "$atik"
	then
		wget "http://download.cloudmakers.eu/$atik"
		sudo dpkg -i "$atik"
	fi
fi
libnova="libnova-0.14-0_0.14.0-2.1_i386.deb"
if ! ls -al "$libnova"
then
	wget "https://launchpadlibrarian.net/179037079/$libnova"
	sudo dpkg -i "$libnova"
fi

# -------------

sudo apt-get -y install libnova-dev libcfitsio-dev libusb-1.0-0-dev zlib1g-dev libgsl-dev \
	build-essential cmake git libjpeg-dev libcurl4-gnutls-dev libtheora-dev libraw-dev \
	pkgconf libswscale-dev libtiff-dev libgphoto2-dev libftdi1-dev libdc1394-22-dev \
	libboost-all-dev libgps-dev libfftw3-dev \
	libavdevice-dev libavformat-dev libavcodec-dev \
	librtlsdr-dev

folder="indi"
if [ ! -d "$folder" ]
then
	#git clone https://github.com/TallFurryMan/indi.git "$folder"
	git clone https://github.com/indilib/indi.git "$folder"
	git clone https://github.com/indilib/indi-3rdparty.git "$folder/3rdparty"
	#pushd $folder
	#git checkout melesse-stable
	#git remote add upstream https://github.com/indilib/indi.git
	#popd
fi

if [ -d "$folder" ]
then
	pushd "$folder"
	#git tag before_pull_$(date +%Y%m%d)
	#git pull upstream master
	popd
fi

build_folder="${folder}_build"
mkdir -p "$build_folder"
cmake_settings="-DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DCCACHE_SUPPORT=ON"
indi_settings_off="-DWITH_MI=OFF -DWITH_FLI=OFF -DWITH_SBIG=OFF -DWITH_INOVAPLX=OFF -DWITH_APOGEE=OFF -DWITH_FFMV=OFF -DWITH_QHY=OFF -DWITH_SSAG=OFF -DWITH_QSI=OFF -DWITH_FISHCAMP=OFF -DWITH_GPSD=OFF -DWITH_DSI=OFF -DWITH_ASTROMECHFOC=OFF -DWITH_LIMESDR=OFF -DWITH_RTLSDR=OFF -DWITH_RADIOSIM=OFF -DWITH_GPSNMEA=OFF -DWITH_ARMADILLO=OFF -DWITH_NIGHTSCAPE=OFF -DWITH_ATIK=On -DWITH_TOUPBASE=OFF -DWITH_ALTAIRCAM=OFF -DWITH_DREAMFOCUSER=OFF -DWITH_AVALON=OFF -DWITH_BEEFOCUS=OFF -DWITH_MAXDOME=OFF -DWITH_NEXDOME=OFF -DWITH_CLOUDWATCHER=OFF -DWITH_WEBCAM=OFF"
#indi_settings_on="EQMOD ATIK"
#indi_settings=$(foreach d,$indi_settings_off,-DWITH_$d=OFF ) $(foreach d,$indi_settings_on,-DWITH_$d=ON )
if ( cd "$build_folder" && cmake $cmake_settings $indi_settings_off "../$folder")
then
	pushd "$build_folder"
	make
	if [ "${DO_INSTALL:-}" = "yes" ] ; then sudo make install ; fi
	popd
else
	exit 1
fi
build_folder="${folder}_libatik_build"
mkdir -p "$build_folder"
if ( cd "$build_folder" && cmake $cmake_settings "../$folder/3rdparty/libatik" )
then
	pushd "$build_folder"
	make
        if [ "${DO_INSTALL:-}" = "yes" ]; then sudo make install ; sudo ldconfig ; fi
	popd
else
	exit 1
fi
build_folder="${folder}_3rdparty_build"
mkdir -p "$build_folder"
if ( cd "$build_folder" && cmake $cmake_settings $indi_settings_off "../$folder/3rdparty" )
then
	pushd "$build_folder"
	make
        if [ "${DO_INSTALL:-}" = "yes" ]; then sudo make install ; fi
	popd
else
	exit 1
fi

exit 0

# -------------

sudo apt-get -y install libwxgtk3.0-dev wx-common wx3.0-i18n gettext

folder="phd2"
[ ! -d "$folder" ] &&
	git clone https://github.com/OpenPHDGuiding/phd2.git "$folder"

if [ -d "$folder" ]
then
	pushd "$folder"
	#git checkout melesse-stable || echo "NO MELESSE-STABLE BRANCH - BYPASSING"
	git pull
	popd
fi

build_folder="${folder}_build"
mkdir -p "$build_folder"
if ( cd "$build_folder" && cmake -DOPENSOURCE_ONLY=1 -DCMAKE_INSTALL_PREFIX=/usr/local "../$folder" )
then
	pushd "$build_folder"
	make
       	if [ "${DO_INSTALL:-}" = "yes" ]; then sudo make install ; fi
	popd
fi

# -------------

folder="gsc"
[ ! -d "$folder" ] &&
	git clone https://git.launchpad.net/gsc "$folder"

if [ -d "$folder" ]
then
	pushd "$folder"
	git checkout melesse-stable || echo "NO MELESSE-STABLE BRANCH - BYPASSING"
	git pull
	popd
fi

build_folder="${folder}_build"
mkdir -p "$build_folder"
if ( cd "$build_folder" && cmake -DOPENSOURCE_ONLY=1 -DCMAKE_INSTALL_PREFIX=/usr/local "../$folder" )
then
	pushd "$build_folder"
	make
       	if [ "${DO_INSTALL:-}" = "yes" ]; then sudo make install ; fi
	popd
fi

# -------------

sudo apt-get install -y netpbm libcairo2-dev libpng-dev libpng-tools python-numpy python-pyfits swig

folder="astrometry"
if [ ! -d "$folder" ]
then
	git clone https://github.com/TallFurryMan/astrometry.net.git "$folder"
	pushd "$folder"
	git remote add upstream https://github.com/dstndstn/astrometry.net.git
	git checkout melesse-stable || git checkout -tb 0.78
	popd
fi

if [ -d "$folder" ]
then
	pushd "$folder"
	git checkout melesse-stable || echo "NO MELESSE-STABLE BRANCH - BYPASSING"
	git pull
	popd
fi

pushd "$folder"
./configure && make all
if [ "$DO_INSTALL" == "yes" ]; then sudo make install ; fi
popd

if [ "$DO_INDEXES" = "yes" ]
then
	pushd "index_files"
	./sync_indexes.sh
	rsync -av index*.fits "../$folder"
	if [ "$DO_INSTALL" == "yes" ]; then sudo make install-indexes ; fi
	popd
fi

# -------------

pushd udev
if [ "${DO_INSTALL:-}" = "yes" ]; then sudo make install ; fi
popd

# -------------

sudo apt-get install -y tigervnc-scraping-server

pushd systemd
if [ "${DO_INSTALL:-}" = "yes" ]
then
	make install
	loginctl enable-linger indi
fi
popd
