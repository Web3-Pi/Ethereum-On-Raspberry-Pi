#!/bin/bash
# Description: This script sorts the server list for Lighthouse. It is used during the startup of Lighthouse.

# Read custom config flags from /boot/firmware/config.txt
config_read_file() {
    (grep -E "^${2}=" -m 1 "${1}" 2>/dev/null || echo "VAR=UNDEFINED") | head -n 1 | cut -d '=' -f 2-;
}

config_get() {
    val="$(config_read_file /boot/firmware/config.txt "${1}")";
    printf -- "%s" "${val}";
}

eth_network="$(config_get eth_network)";
servers_file="/opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/scripts/servers_list_${eth_network}.txt"
best_server=""
best_ping=1000000  # set a very high initial value

# Check if the file exists
if [ ! -f "$servers_file" ]; then
    echo "File $servers_file does not exist."
    best_server="https://beaconstate.info"
    exit 1
fi

while IFS= read -r server; do
    if [ -n "$server" ]; then
        # Remove http:// or https:// prefix if it exists
        clean_server=$(echo "$server" | sed -e 's/^http:\/\///' -e 's/^https:\/\///')

        echo -e "\n$server"

        # Perform 3 pings
        ping_result=$(ping -c 2 -W 0.5 -i 0.5 -4 "$clean_server" 2>/dev/null)

        if [ $? -eq 0 ]; then
            # Extract the average RTT value from the ping result
            avg_rtt=$(echo "$ping_result" | grep 'rtt min/avg/max/mdev' | awk -F '/' '{print $5}')
            echo "$avg_rtt ms"
            if (( $(echo "$avg_rtt < $best_ping" | bc -l) )); then
                best_ping="$avg_rtt"
                best_server="$server"
            fi
        else
            echo "Failed to ping"
        fi
    fi
done < "$servers_file"

echo -e "\n\n"

if [ -n "$best_server" ]; then
    echo "Server with the lowest ping: $best_server ($best_ping ms)"
else
    echo "Failed to obtain ping for any server."
    best_server="https://beaconstate.info"
fi
