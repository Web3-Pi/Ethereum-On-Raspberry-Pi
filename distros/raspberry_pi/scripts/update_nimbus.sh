#!/bin/bash
# Description: This script updates Nimbus to the latest version available in APT.

# Web3 Pi - Nimbus version update via APT
# https://nimbus.guide/keep-updated.html

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
    echo -e "\nRoot privileges are required. Re-run with sudo."
    exit 1
fi

# Get the latest Nimbus version available in APT
apt-get update -qq
NIMBUS_LATEST=$(apt-cache policy nimbus-beacon-node | grep Candidate | awk '{print $2}' | sed 's/+.*//')
NIMBUS_CURRENT=$(nimbus_beacon_node --version | grep -o 'Nimbus beacon node v[0-9.]*' | grep -o '[0-9.]*')

if [ "$NIMBUS_LATEST" = "$NIMBUS_CURRENT" ]; then
    echo "Nimbus is up to date (version: $NIMBUS_CURRENT)."
    exit 0
else
    echo "Update available: current version is $NIMBUS_CURRENT, but latest available in APT is $NIMBUS_LATEST."
fi

# Temporary file for storing names of stopped Nimbus services
TMP_NIMBUS_SERVICES="/tmp/stopped_nimbus_services"

# Stop running Nimbus services
echo -e "\nStopping all running Nimbus services..."
systemctl list-units --type=service --state=running | grep nimbus | awk '{print $1}' > "$TMP_NIMBUS_SERVICES"
while IFS= read -r service; do
    echo "Stopping $service..."
    systemctl stop "$service"
done < "$TMP_NIMBUS_SERVICES"

# Update Nimbus from APT repository
apt-get update -qq
apt-get -y install --only-upgrade nimbus-beacon-node

# Start stopped Nimbus services
if [[ -s "$TMP_NIMBUS_SERVICES" ]]; then
    echo -e "\nStarting Nimbus services..."
    while IFS= read -r service; do
        echo "Starting $service..."
        systemctl start "$service"
    done < "$TMP_NIMBUS_SERVICES"
fi

# Remove temporary file
rm -f "$TMP_NIMBUS_SERVICES"

# Verify update success
NIMBUS_CURRENT=$(nimbus_beacon_node --version | grep -o 'Nimbus beacon node v[0-9.]*' | grep -o '[0-9.]*')
if [ "$NIMBUS_LATEST" = "$NIMBUS_CURRENT" ]; then
    echo -e "\nNimbus updated successfully (version: $NIMBUS_CURRENT)."

    exit 0
else
    echo -e "\nUpdate failed. Current Nimbus version: $NIMBUS_CURRENT, but the latest available is: $NIMBUS_LATEST."
    exit 2
fi

echo -e "\nPlease note that starting Nimbus may take a little while, and monitoring tools like Grafana might require a minute or two to detect that it is running. Be patient."
