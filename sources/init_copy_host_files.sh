#!/bin/bash
#==================== Configuration ========================#
# Configuration generale
. /massa-guard/config/default_config.ini
# Import custom library
. /massa-guard/sources/lib.sh


## Check conf file exist
# Create paths and copy default config.ini as ref
if [ ! -e $PATH_CONF_MASSAGUARD/config.ini ]
then
	mkdir -p $PATH_LOGS_MASSAGUARD
	echo "[$(date +%Y%m%d-%HH%M)][INFO][INIT]CREATE $PATH_LOGS_MASSAGUARD folder" >> $PATH_LOGS_MASSAGUARD/$(date +%Y%m%d)-massa_guard.txt
	mkdir -p $PATH_LOGS_MASSANODE
	echo "[$(date +%Y%m%d-%HH%M)][INFO][INIT]CREATE $PATH_LOGS_MASSANODE folder" >> $PATH_LOGS_MASSAGUARD/$(date +%Y%m%d)-massa_guard.txt
	mkdir -p /massa_mount/config
	echo "[$(date +%Y%m%d-%HH%M)][INFO][INIT]CREATE /massa_mount/config folder" >> $PATH_LOGS_MASSAGUARD/$(date +%Y%m%d)-massa_guard.txt
	cp /massa-guard/config/default_config_template.ini $PATH_CONF_MASSAGUARD/config.ini
	if [ $DISCORD ]; then python3 $PATH_SOURCES/set_config.py "DISCORD_TOKEN" \"$DISCORD\" $PATH_CONF_MASSAGUARD/config.ini ; fi
	if [ $DYNIP ]; then python3 $PATH_SOURCES/set_config.py "DYN_PUB_IP" "$DYNIP" $PATH_CONF_MASSAGUARD/config.ini ; fi
        if [ $NODEPWD ]; then python3 $PATH_SOURCES/set_config.py "NODE_PWD" \"$NODEPWD\" $PATH_CONF_MASSAGUARD/config.ini ; fi
        if [ $WALLETPWD ]; then python3 $PATH_SOURCES/set_config.py "WALLET_PWD" \"$WALLETPWD\" $PATH_CONF_MASSAGUARD/config.ini ; fi
	echo "[$(date +%Y%m%d-%HH%M)][INFO][INIT]COPY default config.ini" >> $PATH_LOGS_MASSAGUARD/$(date +%Y%m%d)-massa_guard.txt
fi
# Load config.ini
source <(grep = $PATH_CONF_MASSAGUARD/config.ini)

# Reset and backup last node log file if exist
BackupLogsNode

## Copy/refresh massa_mount wallet and config files if exists
# Conf node file
if [ -e $PATH_MOUNT/config.toml ]
then
	cp $PATH_MOUNT/config.toml $PATH_NODE_CONF/config.toml
	echo "[$(date +%Y%m%d-%HH%M)][INFO][LOAD]LOAD $PATH_MOUNT/config.toml as ref" >> $PATH_LOGS_MASSAGUARD/$(date +%Y%m%d)-massa_guard.txt
# If ref config.toml dont exist in massa_mount
else
	myIP=$(GetPublicIP)
	echo "[network]" > $PATH_MOUNT/config.toml
	echo "routable_ip = \"$myIP\"" >> $PATH_MOUNT/config.toml
	cp $PATH_MOUNT/config.toml $PATH_NODE_CONF/config.toml
	echo "[$(date +%Y%m%d-%HH%M)][INFO][INIT]Create your default config.toml with $myIP as routable IP" >> $PATH_LOGS_MASSAGUARD/$(date +%Y%m%d)-massa_guard.txt
fi
# Wallet to use
if [ -e $PATH_MOUNT/wallet.dat ]
then
	cp $PATH_MOUNT/wallet.dat $PATH_CLIENT/wallet.dat
	echo "[$(date +%Y%m%d-%HH%M)][INFO][LOAD]LOAD $PATH_MOUNT/wallet.dat as ref" >> $PATH_LOGS_MASSAGUARD/$(date +%Y%m%d)-massa_guard.txt
fi
# Node private key to use
if [ -e $PATH_MOUNT/node_privkey.key ]
then
	# Delete default node_privkey and load ref node_privkey
	rm $PATH_NODE_CONF/node_privkey.key
	cp $PATH_MOUNT/node_privkey.key $PATH_NODE_CONF/node_privkey.key
	echo "[$(date +%Y%m%d-%HH%M)][INFO][LOAD]LOAD $PATH_MOUNT/node_privkey.key as ref" >> $PATH_LOGS_MASSAGUARD/$(date +%Y%m%d)-massa_guard.txt
fi
# Wallet to use to stacke
if [ -e $PATH_MOUNT/staking_keys.json ]
then
	cp $PATH_MOUNT/staking_keys.json $PATH_NODE_CONF/staking_keys.json
	echo "[$(date +%Y%m%d-%HH%M)][INFO][LOAD]LOAD $PATH_MOUNT/staking_keys.json as ref" >> $PATH_LOGS_MASSAGUARD/$(date +%Y%m%d)-massa_guard.txt
fi
# If unreachable node file dont exist
if [ ! -e $PATH_CONF_MASSAGUARD/bootstrappers_unreachable.txt ]
then
	# Create bootstrappers_unreachable.txt
	touch $PATH_CONF_MASSAGUARD/bootstrappers_unreachable.txt
fi

