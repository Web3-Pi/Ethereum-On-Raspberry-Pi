#!/bin/bash
# Description: This script updates Geth to the latest version available in APT.

# Web3 Pi - Geth version update via APT
# https://geth.ethereum.org/docs/getting-started/installing-geth

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
    echo -e "\nRoot privileges are required. Re-run with sudo."
    exit 1
fi

# Get the latest Geth version available in APT
apt-get update -qq
GETH_LATEST=$(apt-cache policy geth | grep Candidate | awk '{print $2}' | sed 's/+.*//')
GETH_CURRENT=$(geth version | grep -o 'Version: [0-9.]*' | grep -o '[0-9.]*')

if [ "$GETH_LATEST" = "$GETH_CURRENT" ]; then
    echo "Geth is up to date (version: $GETH_CURRENT)."
    exit 0
else
    echo "Update available: current version is $GETH_CURRENT, but latest available in APT is $GETH_LATEST."
fi

# Temporary file for storing names of stopped Geth services
TMP_GETH_SERVICES="/tmp/stopped_geth_services"

# Stop running Geth services
echo -e "\nStopping all running Geth services..."
systemctl list-units --type=service --state=running | grep geth | awk '{print $1}' > "$TMP_GETH_SERVICES"
while IFS= read -r service; do
    echo "Stopping $service..."
    systemctl stop "$service"
done < "$TMP_GETH_SERVICES"

# Update Geth from APT repository
apt-get update -qq
apt-get -y install --only-upgrade geth

# Start stopped Geth services
if [[ -s "$TMP_GETH_SERVICES" ]]; then
    echo -e "\nStarting Geth services..."
    while IFS= read -r service; do
        echo "Starting $service..."
        systemctl start "$service"
    done < "$TMP_GETH_SERVICES"
fi

# Remove temporary file
rm -f "$TMP_GETH_SERVICES"

# Verify update success
GETH_CURRENT=$(geth version | grep -o 'Version: [0-9.]*' | grep -o '[0-9.]*')
if [ "$GETH_LATEST" = "$GETH_CURRENT" ]; then
    echo -e "\nGeth updated successfully (version: $GETH_CURRENT)."
    exit 0
else
    echo -e "\nUpdate failed. Current Geth version: $GETH_CURRENT, but the latest available is: $GETH_LATEST."
    exit 2
fi
