#!/bin/bash

# Read custom config flags from /boot/firmware/config.txt
config_read_file() {
    (grep -E "^${2}=" -m 1 "${1}" 2>/dev/null || echo "VAR=UNDEFINED") | head -n 1 | cut -d '=' -f 2-;
}

config_get() {
    val="$(config_read_file /boot/firmware/config.txt "${1}")";
    printf -- "%s" "${val}";
}

# Function: echolog
# Description: Logs messages with a timestamp prefix. If no arguments are provided,
#              reads from stdin and logs each line. Outputs to console and appends to $LOGI file.
LOGI="/var/log/web3pi.log"
echolog(){
    if [ $# -eq 0 ]
    then cat - | while read -r message
        do
                echo "$(date +"[%F %T %Z] -") $message" | tee -a $LOGI
            done
    else
        echo -n "$(date +'[%F %T %Z]') - " | tee -a $LOGI
        echo $* | tee -a $LOGI
    fi
}

# Function: get_install_stage
# Description: A function that retrieves the installation stage from the file /root/.install_stage.
get_install_stage() {
    local file_path=$1
    if [ -f "/root/.install_stage" ]; then
        local number=$(cat "/root/.install_stage")
        echo $number
    else
        echolog "File /root/.install_stage does not exist."
        return 0
    fi
}

# Function: set_status
# Function to write a string to a file with status
set_status() {
  local status="$1"  # Assign the first argument to a local variable
  echo "STAGE $(get_install_stage): $status" > /opt/web3pi/status.txt  # Write the string to the file
  echolog " " 
  echolog "STAGE $(get_install_stage): $status" 
  echolog " " 
}

echolog "Geth run script (geth.sh)"

geth_port="$(config_get geth_port)";
eth_network="$(config_get eth_network)";

# Checking internet connection
echolog "Checking internet connection"

pingServerAdr="github.com"
ping_n=0
ping_max=10

ping -c 1 $pingServerAdr > /dev/null 2>&1
while [ $? -ne 0 ]; do
  echolog -e "\e[1A\e[K $(date): test connection [$ping_n/$ping_max] - ${pingServerAdr}"
  sleep 6
  let "ping_n+=1"
  [[ ${ping_n} -gt ${ping_max} ]] && echolog "Internet access is necessary" && exit 1
  ping -c 1 $pingServerAdr > /dev/null 2>&1
done

echolog "$(date): Connected - ${pingServerAdr}"
echolog "geth_port = ${geth_port}"
echolog "eth_network = ${eth_network}"

echolog "$(date): Connected - ${pingServerAdr}"
echolog "geth_port = ${geth_port}"

echolog "Run Geth"
geth --${eth_network} --authrpc.port 8551 --authrpc.addr 0.0.0.0 --authrpc.vhosts '*' --discovery.port ${geth_port} --port ${geth_port} --authrpc.jwtsecret /home/ethereum/clients/secrets/jwt.hex --datadir /mnt/storage/.ethereum --ws --ws.port 8546 --ws.addr 0.0.0.0 --ws.origins '*' --http --http.port 8545 --http.addr 0.0.0.0 --http.vhosts '*' --http.corsdomain '*' --http.api eth,net,web3 --state.scheme=path