#!/bin/bash
# Description: This script checks if a newer version of Ethereum clients is available.

echo -e "\n--- Latest software versions:"
echo -n -e "------ geth\t\t= "; curl -s "https://api.github.com/repos/ethereum/go-ethereum/releases/latest" | jq -r '.tag_name' | tr -d "v"
echo -n -e "------ nimbus\t\t= "; curl -s "https://api.github.com/repos/status-im/nimbus-eth2/releases/latest" | jq -r '.name' | tr -d 'v'
echo -n -e "------ lighthouse\t= "; curl -s "https://api.github.com/repos/sigp/lighthouse/releases/latest" | jq -r '.tag_name' | tr -d "v"


echo -e "\n--- Installed software versions:"

echo -e "------ Geth"
geth --version

echo -e "\n------ Nimbus"
nimbus_beacon_node --version

echo -e "\n------ Lighthouse"
lighthouse --version
echo -e "\n"
