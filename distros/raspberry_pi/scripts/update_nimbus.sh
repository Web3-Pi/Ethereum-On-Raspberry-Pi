#!/bin/bash
# Description: This script updates Nimbus to the latest version.

#
# Web3 Pi - Nimbus version update
# https://nimbus.guide/keep-updated.html
#

# check for required privileges
if [ "$EUID" -ne 0 ]
  then echo "Root privileges are required. Re-run with sudo"
  exit 1
fi

# Stopping the node
echo "Stop Nimbus service"
sudo systemctl stop w3p_nimbus-beacon.service

# Updating an existing Nimbus installation to the latest version
sudo apt-get update
sudo apt-get -y upgrade nimbus-beacon-node

# Starting the node
echo "Start Nimbus service"
sudo systemctl start w3p_nimbus-beacon.service