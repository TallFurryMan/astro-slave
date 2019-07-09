#!/bin/bash -eux

DO_INSTALL=${DO_INSTALL:-nope}
DO_INDEXES=${DO_INDEXES:-nope}

# -------------

atik="atikccd-1.30-i386.deb"
if ! ls -al "$atik"
then
	wget "http://download.cloudmakers.eu/$atik"
	sudo dpkg -i "$atik"
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
	git clone https://github.com/TallFurryMan/indi.git "$folder"
	pushd $folder
	git checkout melesse-stable
	git remote add upstream https://github.com/indilib/indi.git
	popd
fi

if [ -d "$folder" ]
then
	pushd "$folder"
	git pull upstream master
	popd
fi

build_folder="${folder}_build"
mkdir -p "$build_folder"
if ( cd "$build_folder" && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local "../$folder/libindi" )
then
	pushd "$build_folder"
	make
	if [ "${DO_INSTALL:-}" = "yes" ] ; then sudo make install ; fi
	popd
fi
build_folder="${folder}_3rdparty_build"
mkdir -p "$build_folder"
if ( cd "$build_folder" && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local "../$folder/3rdparty" )
then
	pushd "$build_folder"
	make
        if [ "${DO_INSTALL:-}" = "yes" ]; then sudo make install ; fi
	popd
fi

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

sudo apt-get install -y netpbm libcairo2-dev libpng-dev libpng-tools python-numpy

folder="astrometry"
if [ ! -d "$folder" ]
then
	git clone https://github.com/TallFurryMan/astrometry.net.git "$folder"
	pushd "$folder"
	git remote add upstream https://github.com/dstndstn/astrometry.net.git
	git checkout -tb 0.78
	popd
fi

if [ -d "$folder" ]
then
	pushd "$folder"
	#git checkout melesse-stable || echo "NO MELESSE-STABLE BRANCH - BYPASSING"
	git pull
	popd
fi

if [ "$DO_INDEXES" = "yes" ]
then
	pushd "index_files"
	./sync_indexes.sh
	rsync -av index*.fits "../$folder"
	popd
fi

pushd "$folder"
./configure && make all
if [ "$DO_INSTALL" == "yes" ]; then sudo make install install-indexes ; fi
popd

# -------------

pushd udev
if [ "${DO_INSTALL:-}" = "yes" ]; then sudo make install ; fi
popd

# -------------

pushd systemd
if [ "${DO_INSTALL:-}" = "yes" ]; then make install ; fi
popd
