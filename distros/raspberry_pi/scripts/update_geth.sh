#!/bin/bash
# Description: This script updates Geth to the latest version.

# Web3 Pi - Geth version update
# https://geth.ethereum.org/docs/getting-started/installing-geth
#

# Check if current Geth version is the latest
GETH_LATEST=$(curl -s https://api.github.com/repos/ethereum/go-ethereum/releases/latest | jq '.tag_name' | grep -o '[0-9.]*')
GETH_CURRENT=$(geth version | grep -o 'Version: [0-9.]*' | grep -o [0-9.]*)

if [ "$GETH_LATEST" = "$GETH_CURRENT" ]; then
	echo "Geth is up to date (version: $GETH_CURRENT)."
	exit
else
	echo "Update available: current version is $GETH_CURRENT, but latest version is $GETH_LATEST."
fi

# check for required privileges
if [ "$EUID" -ne 0 ]; then
	echo -e "\nRoot privileges are required. Re-run with sudo"
	exit 1
fi

# Temporary file for storing names of stopped Geth services
TMP_GETH_SERVICES="/tmp/stopped_geth_services"

# Stop running geth services
echo -e "\nStopping all running Geth services..."
for service in $(systemctl list-units --type=service --state=running | grep geth | awk '{print $1}'); do
	echo "Stopping $service..."
	sudo systemctl stop "$service"
	echo "$service" >>"$TMP_GETH_SERVICES"
done

# Updating an existing Geth installation to the latest version
sudo apt-get update
sudo apt-get -y install ethereum
sudo apt-get -y upgrade geth

# Start stopped Geth services
if [[ -s "$TMP_GETH_SERVICES" ]]; then
	echo -e "\nStarting Geth services..."
	while IFS= read -r service; do
		echo "Starting $service..."
		systemctl start "$service"
	done <"$TMP_GETH_SERVICES"
fi

# Remove temporary file
rm -f "$TMP_GETH_SERVICES"

# Check if update was successful
GETH_CURRENT=$(geth version | grep -o 'Version: [0-9.]*' | grep -o [0-9.]*)

if [ "$GETH_LATEST" = "$GETH_CURRENT" ]; then
	echo -e "\nGeth updated succesfully (version: $GETH_CURRENT)."
	exit 0
else
	echo "\nUpdate failed. Current Geth version: $GETH_CURRENT, but the latest is: $GETH_LATEST"
	exit 2
fi