#!/bin/bash
# Description: This script restarts the system while gracefully shutting down Ethereum-related services.
#

# check for required privileges
if [ "$EUID" -ne 0 ]
  then echo "Root privileges are required. Re-run with sudo"
  exit 1
fi

echo "Stop Nimbus service"
sudo systemctl stop w3p_nimbus-beacon.service

echo "Stop Geth service"
sudo systemctl stop w3p_geth.service

echo "Stop Lighthouse service"
sudo systemctl stop w3p_lighthouse-beacon.service

echo "Reboot the OS"
sudo reboot