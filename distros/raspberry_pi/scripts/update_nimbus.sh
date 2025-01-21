#!/bin/bash
# Description: This script updates Nimbus to the latest version.

# Web3 Pi - Nimbus version update
# https://nimbus.guide/keep-updated.html
#

# Check if current Nimbus version is the latest
NIMBUS_LATEST=$(curl -s https://api.github.com/repos/status-im/nimbus-eth2/releases/latest | jq '.tag_name' | grep -o [0-9.]*)
NIMBUS_CURRENT=$(nimbus_beacon_node --version | grep -o 'Nimbus beacon node v[0-9.]*' | grep -o [0-9.]*)

if [ "$NIMBUS_LATEST" = "$NIMBUS_CURRENT" ]; then
	echo "Nimbus is up to date (version: $NIMBUS_CURRENT)."
	exit
else
	echo "Update available: current version is $NIMBUS_CURRENT, but latest version is $NIMBUS_LATEST."
fi

# check for required privileges
if [ "$EUID" -ne 0 ]; then
	echo -e "\nRoot privileges are required. Re-run with sudo"
	exit 1
fi

# Temporary file for storing names of stopped Nimbus services
TMP_NIMBUS_SERVICES="/tmp/stopped_nimbus_services"

# Stop running nimbus services
echo -e "\nStopping all running Nimbus services..."
for service in $(systemctl list-units --type=service --state=running | grep nimbus | awk '{print $1}'); do
	echo "Stopping $service..."
	sudo systemctl stop "$service"
	echo "$service" >>"$TMP_NIMBUS_SERVICES"
done

# Updating an existing Nimbus installation to the latest version
sudo apt-get update
sudo apt-get -y upgrade nimbus-beacon-node

# Start stopped Nimbus services
if [[ -s "$TMP_NIMBUS_SERVICES" ]]; then
	echo -e "\nStarting Nimbus services..."
	while IFS= read -r service; do
		echo "Starting $service..."
		systemctl start "$service"
	done <"$TMP_NIMBUS_SERVICES"
fi

# Remove temporary file
rm -f "$TMP_NIMBUS_SERVICES"

# Check if update was successful
NIMBUS_CURRENT=$(nimbus_beacon_node --version | grep -o 'Nimbus beacon node v[0-9.]*' | grep -o [0-9.]*)

if [ "$NIMBUS_LATEST" = "$NIMBUS_CURRENT" ]; then
	echo -e "\nNimbus updated succesfully (version: $NIMBUS_CURRENT)."
	exit 0
else
	echo "\nUpdate failed. Current Nimbus version: $NIMBUS_CURRENT, but the latest is: $NIMBUS_LATEST"
	exit 2
fi