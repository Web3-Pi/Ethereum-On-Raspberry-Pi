#!/bin/bash

# Read custom config flags from /boot/firmware/config.txt
config_read_file() {
    (grep -E "^${2}=" -m 1 "${1}" 2>/dev/null || echo "VAR=UNDEFINED") | head -n 1 | cut -d '=' -f 2-;
}

config_get() {
    val="$(config_read_file /boot/firmware/config.txt "${1}")";
    printf -- "%s" "${val}";
}


lighthouse_port="$(config_get lighthouse_port)";
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

source /opt/web3pi/Ethereum-On-Raspberry-Pi/scripts/pingServers.sh

echo "$(date): Connected - ${pingServerAdr}"
echo "exec_url = ${exec_url}"
echo "lighthouse_port = ${lighthouse_port}"
echo "best_server = ${best_server}"

echo "Run Lighthouse beacon node"
lighthouse bn --network mainnet --execution-endpoint ${exec_url} --execution-jwt /home/ethereum/clients/secrets/jwt.hex --checkpoint-sync-url ${best_server} --disable-deposit-contract-sync --http --http-address 0.0.0.0 --http-port 5052 --port ${lighthouse_port}
