#!/bin/bash

echo "Installer for 'marlin compile' on 'Ubuntu 18.04'"

# variables
useraccount="marlin"
unitname="marlin_beacon"
marlin_dir="/home/$useraccount/marlin"
openweaver_archive="$HOME/openweaver_ubuntu_18.04_201108-0503.tgz"
conn_beacon="34.82.79.68:8003"

# external beacon
wanip="$(ip route get 1 | head -1 | awk '{print $7}')"	# leave this for autodetect
ep_discovery=8002
ep_heartbeat=8003

# internal beacon
int_beacon="#"	# use "" to enable or "#" to disable
lanip="127.0.0.1"
ip_discovery=9002
ip_heartbeat=9003

# logic
script="$(pwd)/${BASH_SOURCE[0]}"
if [ $USER != "$useraccount" ]; then

	# CHECK root
	if ! [ $(id -u) = 0 ]; then
	   echo "Script must be run as root / sudo."
	   exit 1
	fi
	
	# user account
	adduser --disabled-password --gecos "" $useraccount
	
		# create unitfile
	cat <<EOD > "/etc/systemd/system/$unitname.service"
[Unit]
Description=$unitname
After=network-online.target

[Service]
User=$useraccount
WorkingDirectory=/home/$useraccount/
ExecStart=$marlin_dir/$unitname.sh
StandardOutput=journal
StandardError=journal
Restart=always
RestartSec=3
StartLimitInterval=0
LimitNOFILE=65536
LimitNPROC=65536

[Install]
WantedBy=multi-user.target
EOD
	
	# switch user
	echo "switching to $useraccount by running 'su $useraccount', now run 'bash $script' again"
	su $useraccount
	exit 0
	
else
	
	# location
	cd $HOME
	mkdir -p $marlin_dir || true
	cd $marlin_dir
	
	# extract binary
	tar -xzf $openweaver_archive ./beacon
	chmod +x beacon
	
	# create run script
	cat <<EOD > "$unitname.sh"
#!/bin/bash
$marlin_dir/beacon --discovery_addr "$wanip:$ep_discovery" --heartbeat_addr "$wanip:$ep_heartbeat" --beacon_addr "$conn_beacon"
$int_beacon$marlin_dir/beacon --discovery_addr "$lanip:$ip_discovery" --heartbeat_addr "$lanip:$ip_heartbeat"
EOD

	chmod +x $unitname.sh
	
	echo -e "Run 'sudo systemctl start $unitname' & 'sudo systemctl enable $unitname'"
	echo "To see how your $unitname is doing, run 'sudo journalctl --follow -o cat -u $unitname' (ctrl+c to stop the logview)."

fi
