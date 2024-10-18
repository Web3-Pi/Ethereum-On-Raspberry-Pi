#!/bin/bash

echo "Start sorting server list..."

# File with the list of servers
SERVERS_FILE="/opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/scripts/serversList.txt"

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

echo "The server list has been sorted based on average ping times."
