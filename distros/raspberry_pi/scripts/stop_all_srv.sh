#!/bin/bash
# Description: This script stop all Web3 Pi related services.
#

# check for required privileges
if [ "$EUID" -ne 0 ]
  then echo "Root privileges are required. Re-run with sudo"
  exit 1
fi


echo "Stop BSM service"
sudo systemctl stop w3p_bsm.service

echo "Stop BNM service"
sudo systemctl stop w3p_bnm.service

echo "Stop LCD service"
sudo systemctl stop w3p_lcd.service

echo "Stop w3p_installation-status service"
sudo systemctl stop w3p_installation-status.service

echo "Stop Nimbus service"
sudo systemctl stop w3p_nimbus-beacon.service

echo "Stop Lighthouse service"
sudo systemctl stop w3p_lighthouse-beacon.service

echo "Stop Geth service"
sudo systemctl stop w3p_geth.service

echo "End od script"