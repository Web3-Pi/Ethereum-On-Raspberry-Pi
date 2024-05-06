#!/bin/bash

# Read custom config flags from /boot/firmware/config.txt
config_read_file() {
    (grep -E "^${2}=" -m 1 "${1}" 2>/dev/null || echo "VAR=UNDEFINED") | head -n 1 | cut -d '=' -f 2-;
}

config_get() {
    val="$(config_read_file /boot/firmware/config.txt "${1}")";
    printf -- "%s" "${val}";
}


# STAGE 1 - trustedNodeSync
tn_url="$(config_get nimbus-trusted-node-url)";

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
  [[ ${ping_n} -gt ${ping_max} ]] && echo "Stopping the installation, internet access is necessary" && exit 1
  ping -c 1 $pingServerAdr > /dev/null 2>&1
done

echo "$(date): Connected - ${pingServerAdr}"
  
if [ "$(config_get nimbus-run-mode)" = "full_sync" ]; then
  nimbus_beacon_node trustedNodeSync --network:mainnet --data-dir=/home/ethereum/.nimbus/data/shared_mainnet_0 --trusted-node-url=${tn_url}
fi

if [ "$(config_get nimbus-run-mode)" = "quick_sync" ]; then
  nimbus_beacon_node trustedNodeSync --network:mainnet --data-dir=/home/ethereum/.nimbus/data/shared_mainnet_0 --trusted-node-url=${tn_url} --backfill=false
fi


# STAGE 2 - work mode
nimbus_beacon_node --network:mainnet --data-dir=/home/ethereum/.nimbus/data/shared_mainnet_0 --jwt-secret=/home/ethereum/clients/secrets/jwt.hex --el=http://127.0.0.1:8551 --tcp-port=9000 --udp-port=9000 --rest=true --rest-port=5052 --rest-address=0.0.0.0 --rest-allow-origin='*'
