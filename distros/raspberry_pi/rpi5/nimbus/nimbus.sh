#!/bin/bash

# Read custom config flags from /boot/firmware/config.txt
config_read_file() {
    (grep -E "^${2}=" -m 1 "${1}" 2>/dev/null || echo "VAR=UNDEFINED") | head -n 1 | cut -d '=' -f 2-;
}

config_get() {
    val="$(config_read_file /boot/firmware/config.txt "${1}")";
    printf -- "%s" "${val}";
}


nimbus_port="$(config_get nimbus_port)";
exec_url="$(config_get exec_url)";

# Checking internet connection
echo "Checking internet connection"

pingServerAdr="github.com"
ping_n=0
ping_max=10

ping -c 1 $pingServerAdr > /dev/null 2>&1
while [ $? -ne 0 ]; do
  echo -e "\e[1A\e[K $(date): test connection [$ping_n/$ping_max] - ${pingServerAdr}"
  sleep 6
  let "ping_n+=1"
  [[ ${ping_n} -gt ${ping_max} ]] && echo "Internet access is necessary" && exit 1
  ping -c 1 $pingServerAdr > /dev/null 2>&1
done


echo "$(date): Connected - ${pingServerAdr}"
echo "exec_url = ${exec_url}"
echo "nimbus_port = ${nimbus_port}"

echo "Run Nimbus beacon node - quick sync"
nimbus_beacon_node trustedNodeSync --network:mainnet --data-dir=/home/ethereum/.nimbus/data/shared_mainnet_0 --trusted-node-url=https://mainnet.checkpoint.sigp.io --backfill=false

echo "Run Nimbus beacon node"
nimbus_beacon_node --non-interactive --tcp-port=${nimbus_port} --udp-port=${nimbus_port} --el=${exec_url} --network:mainnet --data-dir=/home/ethereum/.nimbus/data/shared_mainnet_0 --jwt-secret=/home/ethereum/clients/secrets/jwt.hex --rest=true --rest-port=5052 --rest-address=0.0.0.0 --rest-allow-origin='*' --enr-auto-update
