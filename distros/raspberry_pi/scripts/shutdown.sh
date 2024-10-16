#!/bin/bash
#
# Web3 Pi shutdown system
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

echo "Shutdown the OS"
sudo shutdown now