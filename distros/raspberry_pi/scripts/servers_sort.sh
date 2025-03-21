#!/bin/bash
# Description: This script sorts the servers for the Nimbus client. It is used during the startup of Nimbus.

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

echolog "Start sorting server list..."

# File with the list of servers
SERVERS_FILE=$1

echolog "SERVERS_FILE = ${SERVERS_FILE}"

# Check if the file exists
if [ ! -f "$SERVERS_FILE" ]; then
  echo "File $SERVERS_FILE does not exist."
  exit 1
fi

# Temporary file for results
TEMP_FILE="/tmp/sorted_servers.txt"

# Function to calculate average ping time
calculate_average_ping() {
  local server=$1
  local server_address=$(echo "$server" | sed -E 's#^https?://##')
  local avg_ping=$(ping -c 3 -q "$server_address" 2>/dev/null | grep -oP '(?<=rtt min/avg/max/mdev = )[0-9.]+(?=/)')
  echo "$avg_ping"
}

# Read servers, ping them, and sort
{
  while read -r server; do
    if [[ -n "$server" ]]; then
      avg_ping=$(calculate_average_ping "$server")
      if [[ -n "$avg_ping" ]]; then
        echo "$avg_ping $server"
      else
        echo "9999 $server" # Large value if the server is unreachable
      fi
    fi
  done < "$SERVERS_FILE"
} | sort -n > "$TEMP_FILE"

echo -e "\nAfter sort"
cat $TEMP_FILE

# Update the server list file (only server names)
awk '{print $2}' "$TEMP_FILE" > "$SERVERS_FILE"

# Remove the temporary file
rm "$TEMP_FILE"

echolog "The server list has been sorted based on average ping times."
