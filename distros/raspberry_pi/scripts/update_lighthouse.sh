#!/bin/bash
# Description: This script updates Lighthouse to the latest version.

# Web3 Pi - Lighthouse version update
# https://lighthouse-book.sigmaprime.io/installation.html
#

# Check if current lighthouse version is the latest
LIGHTHOUSE_LATEST=$(curl -s https://api.github.com/repos/sigp/lighthouse/releases/latest | jq -r .tag_name)
LIGHTHOUSE_CURRENT=$(lighthouse --version | grep -o 'v[0-9.]*')

if [ "$LIGHTHOUSE_LATEST" = "$LIGHTHOUSE_CURRENT" ]; then
	echo "Lighthouse is up to date (version: $LIGHTHOUSE_CURRENT)."
	exit
else
	echo "Update available: current version is $LIGHTHOUSE_CURRENT, but latest version is $LIGHTHOUSE_LATEST."
fi

# Check for required privileges
if [ "$EUID" -ne 0 ]; then
	echo -e "\nRoot privileges are required. Re-run with sudo"
	exit 1
fi

# Temporary file for storing names of stopped lighthouse services
TMP_LIGHTHOUSE_SERVICES="/tmp/stopped_lighthouse_services"

# Stop every service with lighthouse in name
echo -e "\nStopping all running Lighthouse services..."
for service in $(systemctl list-units --type=service --state=running | grep lighthouse | awk '{print $1}'); do
	echo "Stopping $service..."
	sudo systemctl stop "$service"
	echo "$service" >>"$TMP_LIGHTHOUSE_SERVICES"
done

# Update Lighthouse
echo -e "\nDownloading latest version..."
curl -LO https://github.com/sigp/lighthouse/releases/download/${LIGHTHOUSE_LATEST}/lighthouse-${LIGHTHOUSE_LATEST}-aarch64-unknown-linux-gnu.tar.gz
tar -xvf lighthouse-${LIGHTHOUSE_LATEST}-aarch64-unknown-linux-gnu.tar.gz
mv ./lighthouse /usr/bin/lighthouse
rm -f lighthouse-${LIGHTHOUSE_LATEST}-aarch64-unknown-linux-gnu.tar.gz lighthouse-${LIGHTHOUSE_LATEST}

# Start stopped lighthouse services
if [[ -s "$TMP_LIGHTHOUSE_SERVICES" ]]; then
	echo -e "\nStarting Lighthouse services..."
	while IFS= read -r service; do
		echo "Starting $service..."
		systemctl start "$service"
	done <"$TMP_LIGHTHOUSE_SERVICES"
fi

# Remove temporary file
rm -f "$TMP_LIGHTHOUSE_SERVICES"

# Check if update was successful
LIGHTHOUSE_CURRENT=$(lighthouse --version | grep -o 'v[0-9.]*')

if [ "$LIGHTHOUSE_LATEST" = "$LIGHTHOUSE_CURRENT" ]; then
	echo -e "\nLighthouse updated succesfully (version: $LIGHTHOUSE_CURRENT)."
	exit 0
else
	echo "\nUpdate failed. Current Lighthouse version: $LIGHTHOUSE_CURRENT, but the latest is: $LIGHTHOUSE_LATEST"
	exit 2
fi
