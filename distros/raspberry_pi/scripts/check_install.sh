#!/bin/bash
# Description: Checks the installation and configuration of Web3 Pi image
#
# Web3 Pi - Comprehensive Check Script
#
# This script checks the installation and configuration of Web3 Pi.
# It verifies installed packages, active services, disk and swap usage,
# network connectivity, and other important aspects.
# The output is formatted and color-coded for better readability.

# Check for required privileges
if [ "$EUID" -ne 0 ]; then
    echo "Root privileges are required. Re-run with sudo"
    exit 1
fi

# Log file
LOGI="/var/log/web3pi.log"

# Function: echolog
# Outputs messages in the format:
# Time stamp - [RESULT] - Test name - Additional remarks
# RESULT is color-coded: OK (green), WARN (yellow), ERROR (red)
echolog() {
    # Parameters: RESULT, Test name, Additional remarks
    # Usage: echolog RESULT "Test name" "Additional remarks"
    local timestamp=$(date +"[%F %T %Z]")
    local result="$1"
    local test_name="$2"
    local remarks="$3"

    # Define color codes
    local GREEN="\033[0;32m"
    local YELLOW="\033[1;33m"
    local RED="\033[0;31m"
    local NC="\033[0m"

    # Apply color to RESULT
    case "$result" in
        OK)
            color_result="${GREEN}${result}${NC}"
            ;;
        WARN)
            color_result="${YELLOW}${result}${NC}"
            ;;
        ERROR)
            color_result="${RED}${result}${NC}"
            ;;
        *)
            color_result="$result"
            ;;
    esac

    # Build the message
    local message="$timestamp - [$color_result] - $test_name"
    if [ -n "$remarks" ]; then
        message="$message - $remarks"
    fi

    # Line format for blank parameters
    if [ "$result" == " " ] && [ "$test_name" == " " ]; then
        message="$timestamp - "
    fi
    echo -e "$message" | tee -a "$LOGI"
}

# Required packages and services
required_packages=("chrony" "avahi-daemon" "git-extras" "python3-pip" "python3-netifaces" \
                   "dphys-swapfile" "ethereum" "nimbus-beacon-node" "python3-dev" \
                   "libpython3.12-dev" "python3.12-venv" "software-properties-common" \
                   "apt-utils" "file" "vim" "net-tools" "telnet" \
                   "apt-transport-https" "gcc" "jq" "git" \
                   "libraspberrypi-bin" "iotop" "screen" "bpytop" "ccze")

required_services=("chronyd" "avahi-daemon" "dphys-swapfile")

# --- Section: System Time ---
echolog " " " " " "  # Blank line
echolog "INFO" "Web3 Pi Installation Check Started" " "  # Section header
echolog " " " " " "  # Blank line

# Display system time
check_time_synchronization() {
    if timedatectl show | grep -q "NTPSynchronized=yes"; then
        echolog "OK" "Time Synchronization" "NTP is synchronized."
    else
        echolog "WARN" "Time Synchronization" "NTP is not synchronized."
    fi
}
check_time_synchronization

# Function to check if a package is installed
check_package_installed() {
    dpkg -l | grep -q "^ii  $1"
}

# Function to check if a service is active
check_service_active() {
    systemctl is-active --quiet "$1"
}

# Function to check disk usage
check_disk_usage() {
    local usage=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
    if [ "$usage" -ge 80 ]; then
        echolog "WARN" "Disk Usage" "Disk usage is above threshold: ${usage}%"
    else
        echolog "OK" "Disk Usage" "Disk usage is OK: ${usage}%"
    fi
}

# Function to check swap usage
check_swap_usage() {
    local swap_usage=$(free | grep Swap | awk '{printf "%.2f", $3/$2 * 100.0}')
    if (( $(echo "$swap_usage > 80" | bc -l) )); then
        echolog "WARN" "Swap Usage" "Swap usage is above threshold: ${swap_usage}%"
    else
        echolog "OK" "Swap Usage" "Swap usage is OK: ${swap_usage}%"
    fi
}

# Function to check network connectivity
check_network() {
    if ping -c 1 google.com &> /dev/null; then
        echolog "OK" "Network Connectivity" "Network connectivity is OK."
    else
        echolog "ERROR" "Network Connectivity" "Network connectivity is NOT OK."
    fi
}

# Function to check packet loss
check_packet_loss() {
    local packet_loss=$(ping -c 10 google.com | grep loss | awk '{print $6}' | sed 's/%//')
    if [ "$packet_loss" -gt 0 ]; then
        echolog "WARN" "Packet Loss" "Packet loss detected: ${packet_loss}%"
    else
        echolog "OK" "Packet Loss" "No packet loss detected."
    fi
}

# Function to check number of partitions on a disk
check_partitions() {
    local disk="$1"
    local num_of_partitions=$(lsblk -n -o NAME "${disk}" | wc -l)

    if [ "$num_of_partitions" -ne 1 ]; then
        echolog "ERROR" "Partition Check" "$disk contains $num_of_partitions partitions (exactly one allowed)."
        return 1 # Return error code for more than one partition.
    else
        echolog "OK" "Partition Check" "$disk has exactly one partition."
        return 0 # Success.
    fi
}

# Function to check if Grafana is installed
check_grafana_installed() {
    if check_package_installed "grafana"; then
        echolog "OK" "Grafana Installation" "Grafana is installed."
    else
        echolog "WARN" "Grafana Installation" "Grafana is NOT installed."
    fi
}

# Function to check Wi-Fi power save status
check_wifi_power_save() {
    if command -v iw &>/dev/null; then
        power_save_status=$(iw dev wlan0 get power_save 2>/dev/null)
        if [ "$power_save_status" == "Power save: off" ]; then
            echolog "OK" "Wi-Fi Power Save" "Power save is off."
        elif [ "$power_save_status" == "Power save: on" ]; then
            echolog "WARN" "Wi-Fi Power Save" "Power save is on."
        else
            echolog "ERROR" "Wi-Fi Power Save" "Unknown power save status or error."
        fi
    else
        echolog "ERROR" "Wi-Fi Power Save" "iw command not found."
    fi
}

# Function to check for pending system updates
check_system_updates() {
    if apt list --upgradable 2>/dev/null | grep -q upgradable; then
        echolog "INFO" "System Updates" "There are pending system updates."
    else
        echolog "OK" "System Updates" "System is up-to-date."
    fi
}

# Function to check if NTP is synchronized
check_time_synchronization() {
    if timedatectl show | grep -q "NTPSynchronized=yes"; then
        echolog "OK" "Time Synchronization" "NTP is synchronized."
    else
        echolog "WARN" "Time Synchronization" "NTP is not synchronized."
    fi
}

# Function to check swap space configuration
check_swap_space() {
    local swap_total=$(free -m | awk '/Swap:/ { print $2 }')
    if [ "$swap_total" -ge 2048 ]; then
        echolog "OK" "Swap Space" "Swap space is $swap_total MB."
    else
        echolog "WARN" "Swap Space" "Swap space is less than 2 GB ($swap_total MB)."
    fi
}

# Function to check kernel parameters
check_sysctl_settings() {
    local swappiness=$(sysctl vm.swappiness | awk '{print $3}')
    if [ "$swappiness" -eq 80 ]; then
        echolog "OK" "Sysctl Setting" "vm.swappiness is set to $swappiness."
    else
        echolog "WARN" "Sysctl Setting" "vm.swappiness is $swappiness (recommended: 80)."
    fi
}

# Function to check firewall configuration
check_firewall_configuration() {
    if command -v ufw &>/dev/null; then
        if ufw status | grep -q "Status: active"; then
            echolog "OK" "Firewall" "UFW firewall is active."
        else
            echolog "WARN" "Firewall" "UFW firewall is inactive."
        fi
    else
        echolog "WARN" "Firewall" "UFW is not installed."
    fi
}

# Function to check directories and permissions
check_directories() {
    local dir="/opt/web3pi"
    if [ -d "$dir" ]; then
        echolog "OK" "Directory Check" "$dir exists."
        if [ -w "$dir" ]; then
            echolog "OK" "Directory Permissions" "$dir is writable."
        else
            echolog "WARN" "Directory Permissions" "$dir is not writable."
        fi
    else
        echolog "ERROR" "Directory Check" "$dir does not exist."
    fi
}


# Function to check Geth version
check_geth_version() {
    if command -v geth &>/dev/null; then
        geth_installed_version=$(geth version | awk '/^Version:/{print $2}' | tr -d "v")
        geth_installed_version=${geth_installed_version%-*}  # Remove suffixes after '-'

        geth_latest_version=$(curl -s "https://api.github.com/repos/ethereum/go-ethereum/releases/latest" | jq -r '.tag_name' | tr -d "v")
        geth_latest_version=${geth_latest_version%-*}  # Remove suffixes after '-'

        if [ -z "$geth_latest_version" ]; then
            echolog "ERROR" "Geth Version" "Failed to fetch latest version."
            return
        fi

        if [ "$geth_installed_version" = "$geth_latest_version" ]; then
            echolog "OK" "Geth Version" "Installed version $geth_installed_version is up to date."
        else
            if [ "$(printf '%s\n' "$geth_installed_version" "$geth_latest_version" | sort -V | head -n1)" = "$geth_installed_version" ]; then
                echolog "WARN" "Geth Version" "Installed version $geth_installed_version is older than latest version $geth_latest_version."
            else
                echolog "ERROR" "Geth Version" "Installed version $geth_installed_version is newer than latest version $geth_latest_version."
            fi
        fi
    else
        echolog "WARN" "Geth Version" "Geth is not installed."
    fi
}

# Function to check Nimbus version
check_nimbus_version() {
    if command -v nimbus_beacon_node &>/dev/null; then
        nimbus_installed_version=$(nimbus_beacon_node --version 2>&1 | awk '/^Nimbus beacon node/{print $NF}' | sed 's/^v//; s/-.*$//')

        nimbus_latest_version=$(curl -s "https://api.github.com/repos/status-im/nimbus-eth2/releases/latest" | jq -r '.name' | sed 's/^v//; s/-.*$//')

        if [ -z "$nimbus_latest_version" ]; then
            echolog "ERROR" "Nimbus Version" "Failed to fetch latest version."
            return
        fi

        if [ "$nimbus_installed_version" = "$nimbus_latest_version" ]; then
            echolog "OK" "Nimbus Version" "Installed version $nimbus_installed_version is up to date."
        else
            if [ "$(printf '%s\n' "$nimbus_installed_version" "$nimbus_latest_version" | sort -V | head -n1)" = "$nimbus_installed_version" ]; then
                echolog "WARN" "Nimbus Version" "Installed version $nimbus_installed_version is older than latest version $nimbus_latest_version."
            else
                echolog "ERROR" "Nimbus Version" "Installed version $nimbus_installed_version is newer than latest version $nimbus_latest_version."
            fi
        fi
    else
        echolog "WARN" "Nimbus Version" "Nimbus is not installed."
    fi
}

# Function to check Lighthouse version
check_lighthouse_version() {
    if command -v lighthouse &>/dev/null; then
        lighthouse_installed_version=$(lighthouse --version 2>&1 | head -n1 | awk '{print $2}' | tr -d "v")
        lighthouse_installed_version=${lighthouse_installed_version%-*}  # Remove suffixes after '-'

        lighthouse_latest_version=$(curl -s "https://api.github.com/repos/sigp/lighthouse/releases/latest" | jq -r '.tag_name' | tr -d "v")
        lighthouse_latest_version=${lighthouse_latest_version%-*}  # Remove suffixes after '-'

        if [ -z "$lighthouse_latest_version" ]; then
            echolog "ERROR" "Lighthouse Version" "Failed to fetch latest version."
            return
        fi

        if [ "$lighthouse_installed_version" = "$lighthouse_latest_version" ]; then
            echolog "OK" "Lighthouse Version" "Installed version $lighthouse_installed_version is up to date."
        else
            if [ "$(printf '%s\n' "$lighthouse_installed_version" "$lighthouse_latest_version" | sort -V | head -n1)" = "$lighthouse_installed_version" ]; then
                echolog "WARN" "Lighthouse Version" "Installed version $lighthouse_installed_version is older than latest version $lighthouse_latest_version."
            else
                echolog "ERROR" "Lighthouse Version" "Installed version $lighthouse_installed_version is newer than latest version $lighthouse_latest_version."
            fi
        fi
    else
        echolog "WARN" "Lighthouse Version" "Lighthouse is not installed."
    fi
}

# --- Section: Package Checks ---
echolog " " " " " "  # Blank line
echolog "INFO" "Checking Installed Packages..." " "  # Section header

# Check installed packages
for package in "${required_packages[@]}"; do
    if check_package_installed "$package"; then
        echolog "OK" "Package Check" "Package $package is installed."
    else
        echolog "WARN" "Package Check" "Package $package is NOT installed."
    fi
done

# --- Section: Service Checks ---
echolog " " " " " "  # Blank line
echolog "INFO" "Checking Active Services..." " "  # Section header

# Check active services
for service in "${required_services[@]}"; do
    if check_service_active "$service"; then
        echolog "OK" "Service Check" "Service $service is active."
    else
        echolog "WARN" "Service Check" "Service $service is NOT active."
    fi
done

# --- Section: System Configuration Checks ---
echolog " " " " " "  # Blank line
echolog "INFO" "Checking System Configuration..." " "  # Section header

# Perform system configuration checks
check_system_updates
check_time_synchronization
check_swap_space
check_sysctl_settings
check_directories

# --- Section: Firewall and Security Checks ---
echolog " " " " " "  # Blank line
echolog "INFO" "Checking Firewall Configuration..." " "  # Section header

# Perform firewall and security checks
check_firewall_configuration

# --- Section: Software Version Checks ---
echolog " " " " " "  # Blank line
echolog "INFO" "Checking Software Versions..." " "  # Section header

# Check versions of Geth, Nimbus, and Lighthouse
check_geth_version
check_nimbus_version
check_lighthouse_version

# --- Section: Additional Checks ---
echolog " " " " " "  # Blank line
echolog "INFO" "Performing Additional Checks..." " "  # Section header

# Check Grafana, disk usage, swap usage, network connectivity, packet loss, and Wi-Fi power save
check_grafana_installed
check_disk_usage
check_swap_usage
check_network
check_packet_loss
check_wifi_power_save

# --- Section: Disk Partition Check ---
echolog " " " " " "  # Blank line
echolog "INFO" "Checking Disk Partitions..." " "  # Section header

# Check partitions on the primary disk (assuming /dev/nvme0n1 or /dev/sda1)
DEV_NVME="/dev/nvme0n1"
DEV_USB="/dev/sda"
W3P_DRIVE="NA"

get_best_disk() {
    if stat $DEV_NVME >/dev/null 2>&1; then
        W3P_DRIVE=$DEV_NVME
        echolog "OK" "Disk Detection" "Disk: NVMe detected."
    elif stat $DEV_USB >/dev/null 2>&1; then
        W3P_DRIVE=$DEV_USB
        echolog "OK" "Disk Detection" "Disk: USB detected."
    else
        W3P_DRIVE="NA"
        echolog "ERROR" "Disk Detection" "No suitable disk found."
    fi
}
get_best_disk

echolog "INFO" "Selected Disk" "W3P_DRIVE: $W3P_DRIVE"

# Determine the partition naming based on the disk type
if [[ "$W3P_DRIVE" == "$DEV_NVME" ]]; then
    PARTITION="${W3P_DRIVE}p1"
else
    PARTITION="${W3P_DRIVE}1"
fi
echolog "INFO" "Partition Selection" "PARTITION: $PARTITION"

if ! check_partitions "$PARTITION"; then
    echolog "ERROR" "Partition Check" "Partition check failed for $PARTITION. Exiting."
    exit 1
fi

# --- Section: Installation Stage Check ---
echolog " " " " " "  # Blank line
echolog "INFO" "Checking Installation Stage..." " "  # Section header

# Check installation stage file existence and status
INSTALL_STAGE_FILE="/root/.install_stage"
if [ -f "$INSTALL_STAGE_FILE" ]; then
    install_stage=$(cat "$INSTALL_STAGE_FILE")
    echolog "OK" "Installation Stage" "Installation stage is set to $install_stage."
else
    echolog "WARN" "Installation Stage" "$INSTALL_STAGE_FILE does not exist."
    install_stage=0
fi

# Final status check for completion
if [ "$install_stage" -eq 100 ]; then
    echolog "OK" "Installation Status" "Installation completed successfully."
else
    echolog "WARN" "Installation Status" "Installation is NOT completed. Current stage: $install_stage."
fi

# --- Section: Required Files Check ---
echolog " " " " " "  # Blank line
echolog "INFO" "Checking Required Files..." " "  # Section header

# Additional checks for specific files mentioned in the install script
REQUIRED_FILES=("/opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/install.sh")

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echolog "OK" "File Check" "$file exists."
    else
        echolog "WARN" "File Check" "$file does not exist."
    fi
done

# --- Section: Conclusion ---
echolog " " " " " "  # Blank line
echolog "INFO" "Check Script Finished" " "  # Section footer

exit 0
