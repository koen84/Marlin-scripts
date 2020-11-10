#!/bin/bash

echo "Installer for 'marlin compile' on 'Ubuntu 18.04'"

# variables
useraccount="marlin"

# release identifiers
distro=$(cat /etc/os-release | grep ^ID= | sed -e "s/^ID=//" | sed -e 's/"//g' | sed -e "s/'//g")
distrov=$(cat /etc/os-release | grep ^VERSION_ID= | sed -e "s/^VERSION_ID=//" | sed -e 's/"//g' | sed -e "s/'//g")
timestamp=$(date '+%y%m%d-%H%M')

release_archive="$HOME/openweaver_${distro}_${distrov}_${timestamp}.tgz"


if [ $USER != "$useraccount" ]; then

	# CHECK root
	if ! [ $(id -u) = 0 ]; then
	   echo "Script must be run as root / sudo."
	   exit 1
	fi
	
	# user account
	adduser --disabled-password --gecos "" $useraccount
	
	# packages
	apt-get install git build-essential wget doxygen autoconf libtool
	
	# cmake
	wget -qO- https://github.com/Kitware/CMake/releases/download/v3.18.4/cmake-3.18.4.tar.gz | tar -xz
	cd cmake-*
	./bootstrap && make && make install
	
	
	# switch user
	echo "login as $useraccount by running 'su $useraccount' and start script again"
	su $useraccount
	exit 0
	
else
	
	# get from git
	git clone --recurse-submodules https://github.com/marlinprotocol/OpenWeaver.git
	#git submodule update --init --recursive
	
	# build
	cd OpenWeaver
	mkdir build && cd build
	cmake .. -DCMAKE_BUILD_TYPE=Release && make -j8
	
	# gather binaries
	mkdir ../release
	cp beacon/beacon ../release
	cp relay/eth_relay ../release
	cp goldfish/goldfish ../release
	cp multicastsdk/msggen ../release
	cp integrations/eth/onramp_eth ../release
		
	# create archive
	cd ../release
	echo "Generated on $(date)" > SHA256SUM
	sha256sum * >> SHA256SUM
	tar -czf $release_archive .
	echo "Saved a tarbal with all binaries at $release_archive"
	
fi
