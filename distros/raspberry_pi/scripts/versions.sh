#!/bin/bash

echo -e "\nLatest software versions:\n"
echo -n "geth="; curl -s "https://api.github.com/repos/ethereum/go-ethereum/releases/latest" | jq -r '.tag_name' | tr -d "v"
echo -n "lighthouse="; curl -s "https://api.github.com/repos/sigp/lighthouse/releases/latest" | jq -r '.tag_name' | tr -d "v"
echo -n "nimbus="; curl -s "https://api.github.com/repos/status-im/nimbus-eth2/releases/latest" | jq -r '.name' | tr -d 'v'


echo -e "\nInstalled software versions:\n"

geth --version
echo -e "\n"

nimbus_beacon_node --version
echo -e "\n"

lighthouse --version
echo -e "\n"