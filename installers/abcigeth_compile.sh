#!/bin/bash

echo "Installer for 'marlin compile' on 'Ubuntu 18.04'"

# variables
useraccount="marlin"

# release identifiers
distro=$(cat /etc/os-release | grep ^ID= | sed -e "s/^ID=//" | sed -e 's/"//g' | sed -e "s/'//g")
distrov=$(cat /etc/os-release | grep ^VERSION_ID= | sed -e "s/^VERSION_ID=//" | sed -e 's/"//g' | sed -e "s/'//g")
timestamp=$(date '+%y%m%d-%H%M')

release_archive="$HOME/abcigeth_${distro}_${distrov}_${timestamp}.tgz"


if [ $USER != "$useraccount" ]; then

	# CHECK root
	if ! [ $(id -u) = 0 ]; then
	   echo "Script must be run as root / sudo."
	   exit 1
	fi
	
	# user account
	adduser --disabled-password --gecos "" $useraccount
	
	# packages
	apt-get install git build-essential wget
	
	# golang
	if ! [ -x "$(command -v go)" ]; then
		GO_LATEST=$(curl -sS https://golang.org/VERSION?m=text)
		#GO_LATEST="go1.14.2"
		ARCH=$(dpkg --print-architecture)
		wget https://dl.google.com/go/$GO_LATEST.linux-$ARCH.tar.gz
		tar -C /usr/local -xzf $GO_LATEST.linux-$ARCH.tar.gz
		rm $GO_LATEST.linux-$ARCH.tar.gz
	fi
	
	# switch user
	echo "login as $useraccount by running 'su $useraccount' and start script again"
	su $useraccount
	exit 0
	
else
	
	# profile settings
	echo "export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> ~/.profile
	echo "export GOPATH=$HOME/go" >> ~/.profile
	source ~/.profile
	
	# get from git
	git clone https://github.com/marlinprotocol/abci-geth.git
	
	# build
	cd abci-geth
	make geth
	
	# binaries archive
	mkdir release
	cp build/bin/geth release/abci_geth
	cd release
	echo "Generated on $(date)" > SHA256SUM
	sha256sum * >> SHA256SUM
	tar -czf $release_archive .
	echo "Saved a tarbal with all binaries at $release_archive"
	
fi
