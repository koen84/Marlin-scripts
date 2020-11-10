#!/bin/bash

echo "Installer for 'marlin compile' on 'Ubuntu 18.04'"

# variables
useraccount="marlin"
unitrelay="marlin_relay"
unitabci="abci_geth"
marlin_dir="/home/$useraccount/marlin"
openweaver_archive="$HOME/openweaver_ubuntu_18.04_201108-0503.tgz"
abcigeth_archive="$HOME/abcigeth_ubuntu_18.04_201109-0102.tgz"
ip_beacon="135.181.3.217"
eth_addr="0xD3136a99Be75bEB3565c386cA28076E3A5621C56"
eth_dir="$marlin_dir/ethereum"

# ext beacon ports
ext_beacon=""	# use "" to enable or "#" to disable
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
	
		# create unitfiles
	cat <<EOD > "/etc/systemd/system/$unitrelay.service"
[Unit]
Description=$unitrelay
After=network-online.target

[Service]
User=$useraccount
WorkingDirectory=/home/$useraccount/
ExecStart=$marlin_dir/$unitrelay.sh
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

	cat <<EOD > "/etc/systemd/system/$unitabci.service"
[Unit]
Description=$unitabci
After=network-online.target

[Service]
User=$useraccount
WorkingDirectory=/home/$useraccount/
ExecStart=$marlin_dir/$unitabci.sh
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
	mkdir -p $eth_dir || true
	cd $marlin_dir
	
	# extract binaries
	tar -xzf $openweaver_archive ./eth_relay
	chmod +x eth_relay
	tar -xzf $abcigeth_archive
	chmod +x abci_geth
	
	# create run script
	cat <<EOD > "$unitabci.sh"
#!/bin/bash
$marlin_dir/abci_geth --syncmode light --datadir $eth_dir --metrics --nousb --port 5003 --http.port 5001
EOD
	
	chmod +x $unitabci.sh
	
	cat <<EOD > "$unitrelay.sh"
#!/bin/bash
$ext_beacon$marlin_dir/eth_relay "$ip_beacon:$ep_discovery" "$ip_beacon:$ep_heartbeat" "$eth_dir" --address "$eth_addr"
$int_beacon$marlin_dir/eth_relay "$lanip:$ip_discovery" "$lanip:$ip_heartbeat,$ip_beacon:$ep_heartbeat" "$eth_dir" --address "$eth_addr"
EOD

	chmod +x $unitrelay.sh
	
	echo -e "Run 'sudo systemctl start $unitabci' & 'sudo systemctl enable $unitabci'"
	echo "To see how your $unitabci is doing, run 'sudo journalctl --follow -o cat -u $unitabci' (ctrl+c to stop the logview)."
	
	echo -e "Run 'sudo systemctl start $unitrelay' & 'sudo systemctl enable $unitrelay'"
	echo "To see how your $unitrelay is doing, run 'sudo journalctl --follow -o cat -u $unitrelay' (ctrl+c to stop the logview)."

fi
