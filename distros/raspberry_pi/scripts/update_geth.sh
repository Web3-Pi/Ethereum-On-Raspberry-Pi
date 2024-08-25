#!/bin/bash
#
# Web3Pi - Geth version update
# https://geth.ethereum.org/docs/getting-started/installing-geth
#

# check for required privileges
if [ "$EUID" -ne 0 ]
  then echo "Root privileges are required. Re-run with sudo"
  exit 1
fi

# Stopping the node
echo "Stop Geth service"
sudo systemctl stop w3p_geth.service

# Updating an existing Geth installation to the latest version
sudo apt-get update
sudo apt-get -y install ethereum
sudo apt-get -y upgrade geth

# Starting the node
echo "Start Geth service"
sudo systemctl start w3p_geth.service