#!/bin/bash

# Read custom config flags from /boot/firmware/config.txt
config_read_file() {
    (grep -E "^${2}=" -m 1 "${1}" 2>/dev/null || echo "VAR=UNDEFINED") | head -n 1 | cut -d '=' -f 2-;
}

config_get() {
    val="$(config_read_file /boot/firmware/config.txt "${1}")";
    printf -- "%s" "${val}";
}


geth_port="$(config_get geth_port)";

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
echo "geth_port = ${geth_port}"

echo "Run Geth"
geth --authrpc.port 8551 --authrpc.addr 0.0.0.0 --authrpc.vhosts '*' --discovery.port ${geth_port} --port ${geth_port} --authrpc.jwtsecret /opt/web3pi/clients/secrets/jwt.hex --datadir /mnt/storage/.ethereum --ws --ws.port 8546 --ws.addr 0.0.0.0 --ws.origins '*' --http --http.port 8545 --http.addr 0.0.0.0 --http.vhosts '*' --state.scheme=path