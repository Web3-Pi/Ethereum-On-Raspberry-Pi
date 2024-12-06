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
        echo "$*" | tee -a $LOGI
    fi
}

# Function: get_install_stage
# Description: A function that retrieves the installation stage from the file /root/.install_stage.
get_install_stage() {
    local file_path=$1
    if [ -f "/root/.install_stage" ]; then
        local number=$(cat "/root/.install_stage")
        echo "$number"
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

# Function to calculate average ping time
calculate_average_ping() {
  local server=$1
  local server_address=$(echo "$server" | sed -E 's#^https?://##')
  local avg_ping=$(ping -c 3 -q "$server_address" 2>/dev/null | grep -oP '(?<=rtt min/avg/max/mdev = )[0-9.]+(?=/)')
  echo "$avg_ping"
}

echolog "Nimbus run script (nimbus.sh)"

nimbus_port="$(config_get nimbus_port)";
exec_url="$(config_get exec_url)";
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


# Directory for Nimbus
nimbus_dir="/mnt/storage/.nimbus/data/shared_${eth_network}_0"

echolog "$(date): Connected - ${pingServerAdr}"
echolog "exec_url = ${exec_url}"
echolog "nimbus_port = ${nimbus_port}"
echolog "eth_network = ${eth_network}"
echolog "nimbus_dir = ${nimbus_dir}"

# File with the list of servers
SERVERS_FILE="/opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/scripts/servers_list_${eth_network}.txt"

if [ -f "${SERVERS_FILE}" ]; then
    echolog "SERVERS_FILE = ${SERVERS_FILE}"
else
    echolog "File ${SERVERS_FILE} does not exist."
    return 1
fi

bash /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/scripts/servers_sort.sh $SERVERS_FILE

sleep 1

# Iterate through each server from the list
success=false
while read -r server; do
  if [[ -n "$server" ]]; then
    echolog "Attempting to sync with server: $server"
    avg_ping=$(calculate_average_ping "$server")
    echolog "Average ping = $avg_ping ms"
    
    # Run the Nimbus beacon node command and display output in real time
    output=$(nimbus_beacon_node trustedNodeSync --network=${eth_network} --data-dir="$nimbus_dir" --trusted-node-url="$server" --backfill=false 2>&1)
    # output=$(nimbus_beacon_node trustedNodeSync --network=mainnet --data-dir="$nimbus_dir" --trusted-node-url="$server" --backfill=false 2>&1 | tee /dev/tty)
    
    # Searching for a line containing 'horizon' and extracting the value.
    horizon_value=$(echo "$output" | grep -oP 'horizon=\K\d+')
    echolog "horizon=$horizon_value "
    
    # Check the output for success messages
    if [ "$horizon_value" -gt 0 ]; then
      echolog "Sync successful with server: $server "
      success=true
      break
    else
      echolog "Sync failed with server: $server, trying next server..."
      echolog "Removing $nimbus_dir "
      rm -r $nimbus_dir
    fi
  fi
done < "$SERVERS_FILE"


# If the trustedNodeSync was successful
if [ "$success" = true ]; then
  echolog "Run Nimbus beacon node"
  nimbus_beacon_node --non-interactive --tcp-port=${nimbus_port} --udp-port=${nimbus_port} --el=${exec_url} --network=${eth_network} --data-dir=${nimbus_dir} --jwt-secret=/home/ethereum/clients/secrets/jwt.hex --rest=true --rest-port=5052 --rest-address=0.0.0.0 --rest-allow-origin='*' --enr-auto-update
else
  # If no server was successful
  echolog "All servers failed to complete the trustedNodeSync."
  exit 1
fi
