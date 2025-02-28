#!/bin/bash
#
# Web3 Pi install script
#

SWAPFILE_SIZE=16384
DEV_NVME="/dev/nvme0n1"
DEV_USB="/dev/sda"
W3P_DRIVE="NA"
MIN_VALID_DISK_SIZE=$((150 * 1024 * 1024 * 1024))
FLAG="/root/first-run.flag"
RFLAG="/root/rflag.flag"
ELOG="/root/elog.txt"

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

echolog " "
echolog "Web3 Pi install.sh START - Web3 Pi install.sh START - Web3 Pi install.sh START - Web3 Pi install.sh START - Web3 Pi install.sh START"
echolog " "
timedatectl | echolog


# Function: set_install_stage
# Description: A function that saves the installation stage to the file /root/.install_stage. The file stores a number as text. The beginning of the installation is marked by 0, and the higher the number, the further along the installation process is. A value of 100 indicates the installation is complete.
set_install_stage() {
  local number=$1
  echo $number > /root/.install_stage
}


# If the installation stage file does not exist, create it and initialize it with the value "0".
if [ ! -f "/root/.install_stage" ]; then
  echolog "/root/.install_stage not exist"
  touch /root/.install_stage
  set_install_stage "0" # initial value
  echolog "/root/.install_stage file created and initialized to 0"
fi

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

# Function: set_status_jlog
# Function to write a string to a file with status
STATUS_FILE="/opt/web3pi/status.jlog"
set_status_jlog() {
  local status="$1"
  local level="$2"
  jq -n -c\
    --arg status "$status"\
    --arg stage "$(get_install_stage)"\
    --arg time "$(date +"%Y-%m-%dT%H:%M:%S%z")"\
    --arg level "$([ "$level" = "" ] && echo "INFO" || echo "$level")"\
    '{"time": $time, "status": $status, "level": $level, "stage": $stage}' | tee -a $STATUS_FILE
  #echolog " " 
  #echolog "STAGE $(get_install_stage): $status" 
  #echolog " " 
}

# Function: set_status
# Function to write a string to a file with status
set_status() {
  local status="$1"  # Assign the first argument to a local variable
  echo "STAGE $(get_install_stage): $status" > /opt/web3pi/status.txt  # Write the string to the file
  echolog " " 
  echolog "STAGE $(get_install_stage): $status" 
  echolog " " 
  set_status_jlog "$status" INFO
}

set_status "[install.sh] - Script started"

set_error() {
  local status="$1"
  set_status_jlog "$status" "ERROR"
}

# Terminate the script with saving logs
terminateScript()
{
  echolog "terminateScript()"
  touch $ELOG
  grep "rc.local" /var/log/syslog >> $ELOG 
  exit 1
}

# Read custom config flags from /boot/firmware/config.txt
config_read_file() {
    (grep -E "^${2}=" -m 1 "${1}" 2>/dev/null || echo "VAR=UNDEFINED") | head -n 1 | cut -d '=' -f 2-;
}

config_get() {
    val="$(config_read_file /boot/firmware/config.txt "${1}")";
    printf -- "%s" "${val}";
}
# use example 
# echo "$(config_get lighthouse)";

# STORAGE-RELATED SECTION

get_best_disk() {
  if stat $DEV_NVME >/dev/null 2>&1; then
    W3P_DRIVE=$DEV_NVME
  elif stat $DEV_USB >/dev/null 2>&1; then
    W3P_DRIVE=$DEV_USB
  else
    W3P_DRIVE="NA"
    echolog "No suitable disk found"
    set_error "[install.sh] - No suitable disk found"
    sleep 2
    terminateScript
    #kill -9 $$
  fi
}

verify_size() {
  local part_size="$(lsblk -b -o NAME,SIZE | grep ${1:5})"
  local loc_array=($part_size)

  if [[ ${#loc_array[@]} != 2 ]]; then
    echolog "Unexpected error while reading disk size"
    set_error "[install.sh] - Unexpected error while reading disk size"
    sleep 2
    terminateScript
    #kill -9 $$
  fi

  if [[ ${loc_array[1]} -lt $MIN_VALID_DISK_SIZE ]]; then
    return 1
  fi

  return 0
}

prepare_disk() {
  local DISK="$1"
  local proceed_with_format=true
  local num_of_partitions=$(( $(partx -g ${DISK} | wc -l) ))

  # Different partition naming conventions for potential drives (either "/dev/nvme0n1" or "/dev/sda")
  if [[ "$DISK" == "$DEV_NVME" ]]; then
    local PARTITION="${DISK}p1"
  else
    local PARTITION="${DISK}1"
  fi

  if [[ $num_of_partitions != 1 ]]; then
    echolog "$DISK contains $num_of_partitions partitions (exactly one allowed). Formating."
  else
    # Verify that the provided disk is large enough to store at least part of the swap file and least significant part of consensus client state 
    if ! verify_size $PARTITION; then
      echolog "Disk to small to proceed with installation"
      set_error "[install.sh] - Disk to small to proceed with installation"
      sleep 2
      terminateScript
      #kill -9 $$
    fi

    # Mount disk if it exists and is a Linux partition
    if  [[ -b "$PARTITION" && $(file -s "$PARTITION" | grep -oP 'Linux.*filesystem') ]]; then
      local TMP_DIR=$(mktemp -d)
      mount "$PARTITION" "$TMP_DIR"
    fi

    # Check if the .ethereum exists on the mounted disk
    if [ -d "$TMP_DIR/.ethereum" ]; then
      set_status "[install.sh] - .ethereum already exists on the disk"
      echolog ".ethereum already exists on the disk."

      # Check if the format_me or format_storage file exists
      if [ -f "/boot/firmware/format_storage" ]; then
        echolog "The format_storage file was found. Formatting and mounting..."
        set_status "[install.sh] - The format_storage file was found. Formatting and mounting..."
        rm /boot/firmware/format_storage
      elif [ -f "$TMP_DIR/format_me" ]; then
        echolog "The format_me file was found. Formatting and mounting..."
        set_status "[install.sh] - The format_me file was found. Formatting and mounting..."
      elif [ -f "$TMP_DIR/.format_me" ]; then # for compatibility with prev releases
        echolog "The .format_me file was found. Formatting and mounting..."
        set_status "[install.sh] - The .format_me file was found. Formatting and mounting..."
      else
        echolog "The format flag file was not found. Skipping formatting."
        set_status "[install.sh] - The format flag file was not found. Skipping formatting."
        proceed_with_format=false
      fi

    else
      echolog "The .ethereum does not exist on the disk. Formatting and mounting..."
      set_status "[install.sh] - The .ethereum does not exist on the disk. Formatting and mounting..."
    fi

    # Unmount the disk from the temporary directory
    if mountpoint -q "$TMP_DIR"; then
      umount "$TMP_DIR"
      rm -r "$TMP_DIR"
    fi
  fi

  if [ "$proceed_with_format" = true ]; then
    # Create a new partition and format it as ext4
    echolog "Creating new partition and formatting disk: $DISK..."
    set_status "[install.sh] - Creating new partition and formatting disk: $DISK..."

    wipefs -a "$DISK"
    sgdisk -n 0:0:0 "$DISK"
    mkfs.ext4 -F "$PARTITION" || {
      echolog "Unable to format $PARTITION"
      set_error "[install.sh] - Unable to format $PARTITION"
      sleep 2
      return 1
    }

    echolog "Removing FS reserved blocks on partion $PARTITION"
    set_status "[install.sh] - Removing FS reserved blocks on partion $PARTITION"
    tune2fs -m 0 $PARTITION
  fi

  echolog "Mounting $PARTITION as /mnt/storage"
  set_status "[install.sh] - Mounting $PARTITION as /mnt/storage"
  mkdir /mnt/storage
  echo "$PARTITION /mnt/storage ext4 defaults,noatime 0 2" >> /etc/fstab && mount /mnt/storage

  set_status "[install.sh] - Storage is ready"
}


# Firmware updates
if [ "$(get_install_stage)" -eq 1 ]; then
  
  set_status "[install.sh] - Stop unattended-upgrades.service"
  systemctl stop unattended-upgrades
  systemctl disable unattended-upgrades

  # Ubuntu 24.04 have old rpi-eeprom app
  git-force-clone -b master https://github.com/raspberrypi/rpi-eeprom /opt/web3pi/rpi-eeprom
  /opt/web3pi/rpi-eeprom/test/install -b

  output_reu=""
  # Detect SoC version
  if [ -f /proc/device-tree/compatible ]; then
      SOC_COMPATIBLE=$(tr -d '\0' < /proc/device-tree/compatible)

      if echo "$SOC_COMPATIBLE" | grep -q "brcm,bcm2711"; then
          set_status "[install.sh] - Detected SoC: BCM2711 (e.g., Raspberry Pi 4/400/CM4)"
          set_status "[install.sh] - Check for firmware updates for the Raspberry Pi SBC"
          output_reu=$(rpi-eeprom-update -a)
          echolog "cmd: rpi-eeprom-update -a \n${output_reu}"
      elif echo "$SOC_COMPATIBLE" | grep -q "brcm,bcm2712"; then
          set_status "[install.sh] - Detected SoC: BCM2712 (e.g., Raspberry Pi 5/500/CM5)"
          set_status "[install.sh] - Check for firmware updates for the Raspberry Pi SBC"
          # Run the firmware update command
          output_reu=$(rpi-eeprom-update -a)
          echolog "cmd: rpi-eeprom-update -a \n${output_reu}"
      else
          set_error "[install.sh] - Detected another model (not BCM2711 or BCM2712)."
          terminateScript
      fi
  else
      set_error "[install.sh] - No /proc/device-tree/compatible file found — cannot detect SoC this way."
      terminateScript
  fi

  rebootReq=false
  # Check if the output contains the message indicating a reboot is needed
  if echo "$output_reu" | grep -q "EEPROM updates pending. Please reboot to apply the update."; then
      rebootReq=true
      set_status "[install.sh] - Firmware will be updated after reboot. rebootReq=true"
      set_status "[install.sh] - Change the stage to 2"
      set_install_stage 2
  elif echo "$output_reu" | grep -q "UPDATE SUCCESSFUL"; then
      rebootReq=true
      set_status "[install.sh] - Firmware updated with flashrom. rebootReq=true"
      set_status "[install.sh] - Change the stage to 2"
      set_install_stage 2
  fi

  # Check the value of rebootReq
  if [ "$rebootReq" = true ]; then
      echo "[install.sh] - EEPROM update requires a reboot. Restarting the device..."
      echo "[install.sh] - EEPROM update requires a reboot. Restarting the device..."
      set_status "[install.sh] - Rebooting after rpi-eeprom-update"
      sleep 5
      reboot
      exit 1
  else
      echo "[install.sh] - No firmware update required"
      echo "[install.sh] - No firmware update required"
      set_status "[install.sh] - No firmware update required"
      sleep 3
  fi

  set_status "[install.sh] - Change the stage to 2"
  set_install_stage 2
fi

# MAIN installation part
if [ "$(get_install_stage)" -eq 2 ]; then

  set_status "[install.sh] - Main installation part"
  sleep 2

  set_status "[install.sh] - Stop unattended-upgrades.service"
  systemctl stop unattended-upgrades
  systemctl disable unattended-upgrades

## 0. Add some necessary repositories ######################################################  

  set_status "[install.sh] - Sync time with NTP server (chronyd -q)"
  chronyd -q

  timedatectl | echolog

  sleep 3

  set_status "[install.sh] - Adding Ethereum repositories"
  sudo add-apt-repository -y ppa:ethereum/ethereum
  
  set_status "[install.sh] - Adding Nimbus repositories"
  echo 'deb https://apt.status.im/nimbus all main' | tee /etc/apt/sources.list.d/nimbus.list
  # Import the GPG key
  curl https://apt.status.im/pubkey.asc -o /etc/apt/trusted.gpg.d/apt-status-im.asc

  set_status "[install.sh] - Adding Grafana repositories"
  wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
  echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | tee -a /etc/apt/sources.list.d/grafana.list
  

## 1. Install some required dependencies ####################################################
 
  set_status "[install.sh] - Required dependencies"
  sleep 2

  set_status "[install.sh] - Refreshes the package lists"
  apt-get update
  
  set_status "[install.sh] - Installing required dependencies 1/3"
  apt-get -y install iw python3-dev libpython3.12-dev python3.12-venv
  
  set_status "[install.sh] - Installing required dependencies 2/3"
  apt-get -y install software-properties-common apt-utils file vim net-tools telnet apt-transport-https
  
  set_status "[install.sh] - Installing required dependencies 3/3"
  apt-get -y install gcc jq git libraspberrypi-bin iotop screen bpytop ccze
  
## 2. STORAGE SETUP ##########################################################################

#  ToDo: This should be separete step

  # Prepare drive to mount /mnt/storage
  set_status "[install.sh] - Looking for a valid drive for Blockchain copy"
  get_best_disk
  echolog "W3P_DRIVE=$W3P_DRIVE"

  # Check if /boot/firmware is mounted
  mount_point=$(mount | grep ' /boot/firmware ' | awk '{print $1}')

  # Check if the mount point starts with $DEV_NVME or $DEV_USB
  if [[ $mount_point == $DEV_NVME* ]]; then
      set_status "[install.sh] - /boot/firmware is mounted on an NVMe device: $mount_point"
  elif [[ $mount_point == $DEV_USB* ]]; then
      set_status "[install.sh] - /boot/firmware is mounted on a USB device: $mount_point"
  else
      set_status "[install.sh] - /boot/firmware is mounted on device: $mount_point"
      set_status "[install.sh] - Preparing $W3P_DRIVE for installation"
      prepare_disk $W3P_DRIVE
  fi

## 3. ACCOUNT CONFIGURATION ###################################################################

  set_status "[install.sh] - Account configuration"

  # Create Ethereum account
  echolog "[install.sh] - Creating ethereum user"
  if ! id -u ethereum >/dev/null 2>&1; then
    adduser --disabled-password --gecos "" ethereum
  fi

  echo "ethereum:ethereum" | chpasswd
  for GRP in sudo netdev audio video dialout plugdev; do
    adduser ethereum $GRP
  done

  # Force password change on first login
  chage -d 0 ethereum

  mkdir /mnt/storage
  chown ethereum:ethereum /mnt/storage/
  
## 4. SWAP SPACE CONFIGURATION ###################################################################
  
  set_status "[install.sh] - SWAP configuration"
  
  # Install dphys-swapfile package
  apt-get -y install dphys-swapfile

  # Configure swap file location and size
  sed -i "s|#CONF_SWAPFILE=.*|CONF_SWAPFILE=/mnt/storage/swapfile|" /etc/dphys-swapfile
  sed -i "s|#CONF_SWAPSIZE=.*|CONF_SWAPSIZE=$SWAPFILE_SIZE|" /etc/dphys-swapfile
  sed -i "s|#CONF_MAXSWAP=.*|CONF_MAXSWAP=$SWAPFILE_SIZE|" /etc/dphys-swapfile

  # Check total RAM in kB
  total_ram=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  set_status "[install.sh] - Detected RAM: ${total_ram} kB"

  # Conditions
  if [ "$total_ram" -lt 7000000 ]; then
      set_error "[install.sh] - Not enough RAM for Web3 Pi. Minimum required is 8 GB"
      terminateScript
  elif [ "$total_ram" -ge 15000000 ]; then
      set_status "[install.sh] - Setting vm.swappiness to 10"
      # Enable dphys-swapfile service
      systemctl enable dphys-swapfile
      {
        echo "vm.min_free_kbytes=65536"
        echo "vm.swappiness=10"
        echo "vm.vfs_cache_pressure=100"
        echo "vm.dirty_background_ratio=10"
        echo "vm.dirty_ratio=20"
      } >> /etc/sysctl.conf
  elif [ "$total_ram" -ge 7000000 ]; then
      set_status "[install.sh] - Setting vm.swappiness to 80"
      # Enable dphys-swapfile service
      systemctl enable dphys-swapfile
      {
        echo "vm.min_free_kbytes=65536"
        echo "vm.swappiness=80"
        echo "vm.vfs_cache_pressure=500"
        echo "vm.dirty_background_ratio=1"
        echo "vm.dirty_ratio=50"
      } >> /etc/sysctl.conf
  else
      set_error "[install.sh] - RAM does not match expected specifications."
      terminateScript
  fi



## 5. ETHEREUM INSTALLATION #######################################################################
 
  set_status "[install.sh] - Ethereum Clients Installation"

  # Ethereum software installation
  
  # Install Ethereum packages
  echolog "Installing Ethereum packages"


  # Install Layer 1
  set_status "[install.sh] - Ethereum Installation"
  apt-get -y install ethereum
  
  set_status "[install.sh] - Nimbus Installation"
  apt-get -y install nimbus-beacon-node
 
  set_status "[install.sh] - Lighthouse Installation"
  LH_RELEASE_URL="https://api.github.com/repos/sigp/lighthouse/releases/latest"
  LH_BINARIES_URL="$(curl -s $LH_RELEASE_URL | jq -r ".assets[] | select(.name) | .browser_download_url" | grep aarch64-unknown-linux-gnu.tar.gz$)"

  echolog Downloading Lighthouse URL: $LH_BINARIES_URL
  
  # Download
  set_status "[install.sh] - Lighthouse Installation - download"
  wget -O /tmp/lighthouse.tar.gz $LH_BINARIES_URL
  # Untar
  set_status "[install.sh] - Lighthouse Installation - extract"
  tar -xzvf /tmp/lighthouse.tar.gz -C /tmp/
  # Cleanup
  set_status "[install.sh] - Lighthouse Installation - cleanup"
  rm /tmp/lighthouse.tar.gz

  set_status "[install.sh] - Lighthouse Installation - copy to /usr/bin"
  cp /tmp/lighthouse /usr/bin

  lighthouse --version

## 6. MISC CONF STEPS ##############################################################################

  set_status "[install.sh] - Miscellaneous configuration steps"
  sleep 2

  # Install ufw
  set_status "[install.sh] - Istalling UFW (firewall)"
  apt-get -y install ufw
  # ufw --force disable


  set_status "[install.sh] - Configuring UFW (firewall)"

  ufw allow 22/tcp comment "SSH"

  geth_port="$(config_get geth_port)";
  ufw allow ${geth_port}/tcp comment "Geth: peer-to-peer (P2P) communication"
  ufw allow ${geth_port}/udp comment "Geth: peer-to-peer (P2P) communication"
  ufw allow 8545/tcp comment "Geth: JSON-RPC server (HTTP)"
  ufw allow 8546/tcp comment "Geth: WebSocket server"
  # If the execution and consensus clients are on the same device, this port does not need to be open in the firewall, as communication occurs over localhost.
  ufw allow 8551/tcp comment "Geth: Engine API, enabling communication between the execution and consensus layers"

  nimbus_port="$(config_get nimbus_port)";
  ufw allow ${nimbus_port}/tcp comment "Nimbus/Lighthouse: peer-to-peer (P2P) communication"
  ufw allow ${nimbus_port}/udp comment "Nimbus/Lighthouse: peer-to-peer (P2P) communication"

  lighthouse_port="$(config_get lighthouse_port)";
  # If Lighthouse is not in use, this port can be closed.
  ufw allow ${lighthouse_port}/tcp comment "Lighthouse: p2p"
  ufw allow 3000/tcp comment "Grafana: web interface"

  # If the database and cgrafana are on the same device, this port does not need to be open in the firewall, as communication occurs over localhost.
  # ufw allow 8086/tcp comment "InfluxDB: HTTP API"

  ufw allow 80/tcp comment "basic-status-http: web interface"

  ufw allow 7197/tcp comment "basic-system-monitor: JSON"

  ufw allow 5353/udp comment "avahi-daemon: mDNS"


  set_status "[install.sh] - Enable UFW (firewall)"
  sleep 2
  ufw --force enable
  ufw status verbose | echolog
 
## 7. MONITORING ####################################################################################

  #set_status "MONITORING instalation"
  set_status "[install.sh] - Monitoring services installation"
  sleep 2

  # Installing InfluxDB
  set_status "[install.sh] - Installing InfluxDB v1.8.10"
  dpkg -i /opt/web3pi/influxdb/influxdb_1.8.10_arm64.deb
  sed -i "s|# flux-enabled =.*|flux-enabled = true|" /etc/influxdb/influxdb.conf

  set_status "[install.sh] - Start influxdb.service"
#  systemctl enable influxdb
  systemctl start influxdb
  sleep 10

  set_status "[install.sh] - Configuring InfluxDB"
  influx -execute 'CREATE DATABASE ethonrpi'
  influx -execute "CREATE USER geth WITH PASSWORD 'geth'"
  
  # Installing Grafana
  set_status "[install.sh] - Installing Grafana"
  apt-get -y install grafana

  set_status "[install.sh] - Configuring Grafana"
  # Copy datasources.yaml for grafana
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/grafana/yaml/datasources.yaml /etc/grafana/provisioning/datasources/datasources.yaml

  # Copy dashboards.yaml for grafana
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/grafana/yaml/dashboards.yaml /etc/grafana/provisioning/dashboards/dashboards.yaml

  grafana-server
#  systemctl enable grafana-server
  systemctl start grafana-server
 

## 8. SERVICES CONFIGURATION ###########################################################################

  set_status "[install.sh] - Services configuration"
  

  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/bsm/w3p_bsm.service /etc/systemd/system/w3p_bsm.service
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/bnm/w3p_bnm.service /etc/systemd/system/w3p_bnm.service
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/geth/w3p_geth.service /etc/systemd/system/w3p_geth.service
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/lighthouse/w3p_lighthouse-beacon.service /etc/systemd/system/w3p_lighthouse-beacon.service
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/nimbus/w3p_nimbus-beacon.service /etc/systemd/system/w3p_nimbus-beacon.service
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/gssm/w3p_gssm.service /etc/systemd/system/w3p_gssm.service


## 9. CLIENTS CONFIGURATION ############################################################################
  
  set_status "[install.sh] - Clients configuration"

  echolog "Configuring clients run scripts"
  mkdir /home/ethereum/clients
  
  mkdir /home/ethereum/clients/geth
  mkdir /home/ethereum/clients/lighthouse
  mkdir /home/ethereum/clients/nimbus
  
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/geth/geth.sh /home/ethereum/clients/geth/geth.sh
  chmod +x /home/ethereum/clients/geth/geth.sh
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/lighthouse/lighthouse.sh /home/ethereum/clients/lighthouse/lighthouse.sh
  chmod +x /home/ethereum/clients/lighthouse/lighthouse.sh
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/nimbus/nimbus.sh /home/ethereum/clients/nimbus/nimbus.sh
  chmod +x /home/ethereum/clients/nimbus/nimbus.sh

  set_status "[install.sh] - Monitoring configuration"
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/bsm/run.sh /opt/web3pi/basic-system-monitor/run.sh
  chmod +x /opt/web3pi/basic-system-monitor/run.sh

  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/bnm/run.sh /opt/web3pi/basic-eth2-node-monitor/run.sh
  chmod +x /opt/web3pi/basic-eth2-node-monitor/run.sh

  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/gssm/run.sh /opt/web3pi/geth-sync-stages-monitoring/run.sh
  chmod +x /opt/web3pi/geth-sync-stages-monitoring/*.sh

  chown -R ethereum:ethereum /home/ethereum/clients
  
## 10. ADDITIONAL DIRECTORIES ###########################################################################

  set_status "[install.sh] - Adding client directories required to run the node"

  echolog "Adding client directories required to run the node"
  sudo -u ethereum mkdir -p /home/ethereum/clients/secrets/

  set_status "[install.sh] - Prepare the jwt.hex file"
  # Check if the file exists
  if [ -f "/boot/firmware/jwt.hex" ]; then
      # Move the file to the destination directory
      mv "/boot/firmware/jwt.hex" "/home/ethereum/clients/secrets/"
      echolog "The /boot/firmware/jwt.hex file has been moved to /home/ethereum/clients/secrets/"
  else
      echolog "The /boot/firmware/jwt.hex file does not exist. Generating new jwt.hex file"
      sudo -u ethereum openssl rand -hex 32 | sudo -u ethereum tr -d "\n" | sudo -u ethereum tee /home/ethereum/clients/secrets/jwt.hex
      echolog " "
  fi
  
  set_status "[install.sh] - Copying scripts to /home/ethereum/scripts"
  ln -s /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/scripts/ /home/ethereum/
  chmod +x /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/scripts/*.sh
  
  chown -R ethereum:ethereum /home/ethereum/clients/secrets
  
## 11. CONVENIENCE CONFIGURATION ########################################################################

  set_status "[install.sh] - Convenience configuration"

  # Force colored prompt
  echolog "Setting up a colored prompt"
  if [[ ! -f "/home/ethereum/.bashrc" ]]; then
    cp /etc/skel/.bashrc /home/ethereum
  fi

  sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/ethereum/.bashrc
  chown ethereum:ethereum /home/ethereum/.bashrc

  set_status "[install.sh] - Create a virtual environment for basic-system-monitor"
  echolog "basic-system-monitor venv conf"
  cd /opt/web3pi/basic-system-monitor
  python3 -m venv venv

  chmod +x /opt/web3pi/basic-system-monitor/run.sh
  
  set_status "[install.sh] - Create a virtual environment for basic-eth2-node-monitor"
  echolog "basic-eth2-node-monitor venv conf"
  cd /opt/web3pi/basic-eth2-node-monitor
  python3 -m venv venv

  chmod +x /opt/web3pi/basic-eth2-node-monitor/run.sh

  set_status "[install.sh] - Create a virtual environment for geth-sync-stages-monitoring"
  echolog "geth-sync-stages-monitoring venv conf"
  cd /opt/web3pi/geth-sync-stages-monitoring
  python3 -m venv venv

  chmod +x /opt/web3pi/geth-sync-stages-monitoring/*.sh

  chown -R ethereum:ethereum /opt/web3pi

## 12. CLEANUP ###########################################################################################

  set_status "[install.sh] - Cleanup"

  # RPi imager fix
  chown root:root /etc

  # Disable root user
  passwd -l root

  # Delete default user
  defUserName=$(grep 'name:' /boot/firmware/user-data | sed -n 's/.*- name: //p')
  echolog "defUserName="$defUserName 
  deluser $defUserName

## 13. READ CONFIG FROM CONFIG.TXT ########################################################################

  set_status "[install.sh] - Read the services configuration from config.txt"

  # Read custom settings from /boot/firmware/config.txt - [Web3Pi] tag
  echolog "Read custom settings from /boot/firmware/config.txt - [Web3Pi] tag" 

  systemctl daemon-reload
  
  if [ "$(config_get influxdb)" = "true" ]; then
    echolog "Service config: Enable influxdb.service"
    systemctl enable influxdb.service
#    systemctl start influxdb.service
  elif  [ "$(config_get influxdb)" = "false" ]; then
    echolog "Service config: Disable influxdb.service"
    systemctl disable influxdb.service
  else
    echolog "Service config: NoChange influxdb.service"
  fi

  if [ "$(config_get grafana)" = "true" ]; then
    echolog "Service config: Enable grafana-server.service"
    systemctl enable grafana-server.service
 #   systemctl start grafana-server.service
  elif  [ "$(config_get grafana)" = "false" ]; then
    echolog "Service config: Disable grafana-server.service"
    systemctl disable grafana-server.service
  else
    echolog "Service config: NoChange grafana-server.service"
  fi
 
  if [ "$(config_get bsm)" = "true" ]; then
    echolog "Service config: Enable w3p_bsm.service"
    systemctl enable w3p_bsm.service
  # systemctl start w3p_bsm.service
  elif  [ "$(config_get bsm)" = "false" ]; then
    echolog "Service config: Disable w3p_bsm.service"
    systemctl disable w3p_bsm.service
  else
    echolog "Service config: NoChange w3p_bsm.service"
  fi

  if [ "$(config_get bnm)" = "true" ]; then
    echolog "Service config: Enable w3p_bnm.service"
    systemctl enable w3p_bnm.service
  # systemctl start w3p_bnm.service
  elif  [ "$(config_get bnm)" = "false" ]; then
    echolog "Service config: Disable w3p_bnm.service"
    systemctl disable w3p_bnm.service
  else
    echolog "Service config: NoChange w3p_bnm.service"
  fi

  if [ "$(config_get gssm)" = "true" ]; then
    echolog "Service config: Enable gssm.service"
    systemctl enable w3p_gssm.service
  #  systemctl start w3p_gssm.service
  elif  [ "$(config_get bnm)" = "false" ]; then
    echolog "Service config: Disable w3p_gssm.service"
    systemctl disable w3p_gssm.service
  else
    echolog "Service config: NoChange w3p_gssm.service"
  fi

  if [ "$(config_get geth)" = "true" ]; then
    echolog "Service config: Enable w3p_geth.service"
    systemctl enable w3p_geth.service
  # systemctl start w3p_geth.service
  elif  [ "$(config_get geth)" = "false" ]; then
    echolog "Service config: Disable w3p_geth.service"
    systemctl disable w3p_geth.service
  else
    echolog "Service config: NoChange w3p_geth.service"
  fi

  if [ "$(config_get lighthouse)" = "true" ]; then
    echolog "Service config: Enable w3p_lighthouse-beacon.service"
    systemctl enable w3p_lighthouse-beacon.service
  # systemctl start w3p_lighthouse-beacon.service
  elif  [ "$(config_get lighthouse)" = "false" ]; then
    echolog "Service config: Disable w3p_lighthouse-beacon.service"
    systemctl disable w3p_lighthouse-beacon.service
  else
    echolog "Service config: NoChange w3p_lighthouse-beacon.service"
  fi


  if [ "$(config_get nimbus)" = "true" ]; then
    echolog "Service config: Enable w3p_nimbus-beacon.service"
    systemctl enable w3p_nimbus-beacon.service
  # systemctl start w3p_nimbus-beacon.service
  elif  [ "$(config_get nimbus)" = "false" ]; then
    echolog "Service config: Disable w3p_nimbus-beacon.service"
    systemctl disable w3p_nimbus-beacon.service
  else
    echolog "Service config: NoChange w3p_nimbus-beacon.service"
  fi
  


  # Next line creates an empty file so it won't run the next boot
  set_status "[install.sh] - Create ${FLAG}"
  touch $FLAG

  set_status "[install.sh] - Change the stage to 100"
  set_install_stage 100

  set_status "[install.sh] - Write rc.local logs to ${FLAG}"
  grep "rc.local" /var/log/syslog >> $FLAG
  
  set_status "[install.sh] - Run check_install.sh script"
  bash /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/scripts/check_install.sh

  set_status "[install.sh] - Rebooting..."
  sleep 3
  reboot

fi


if [ "$(get_install_stage)" -eq 100 ]; then

  set_status "[install.sh] - Not First Run"
  sleep 2


  # WiFi stability fix
  set_status "[install.sh] - Set wlan0 power_save off"
  iw dev wlan0 set power_save off
  sleep 1

  # Read custom settings from /boot/firmware/config.txt - [Web3Pi] tag
  set_status "[install.sh] - Read the services configuration from config.txt"
  
  if [ "$(config_get influxdb)" = "true" ]; then
    echolog "Service config: Enable influxdb.service"
    systemctl enable influxdb.service
    systemctl start influxdb.service
  elif  [ "$(config_get influxdb)" = "false" ]; then
    echolog "Service config: Disable influxdb.service"
    systemctl disable influxdb.service
  else
    echolog "Service config: NoChange influxdb.service"
  fi

  if [ "$(config_get grafana)" = "true" ]; then
    echolog "Service config: Enable grafana-server.service"
    systemctl enable grafana-server.service
    systemctl start grafana-server.service
  elif  [ "$(config_get grafana)" = "false" ]; then
    echolog "Service config: Disable grafana-server.service"
    systemctl disable grafana-server.service
  else
    echolog "Service config: NoChange grafana-server.service"
  fi
  
  if [ "$(config_get bsm)" = "true" ]; then
    echolog "Service config: Enable w3p_bsm.service"
    systemctl enable w3p_bsm.service
    systemctl start w3p_bsm.service
  elif  [ "$(config_get bsm)" = "false" ]; then
    echolog "Service config: Disable w3p_bsm.service"
    systemctl disable w3p_bsm.service
  else
    echolog "Service config: NoChange w3p_bsm.service"
  fi

  if [ "$(config_get bnm)" = "true" ]; then
    echolog "Service config: Enable w3p_bnm.service"
    systemctl enable w3p_bnm.service
    systemctl start w3p_bnm.service
  elif  [ "$(config_get bnm)" = "false" ]; then
    echolog "Service config: Disable w3p_bnm.service"
    systemctl disable w3p_bnm.service
  else
    echolog "Service config: NoChange w3p_bnm.service"
  fi

  if [ "$(config_get gssm)" = "true" ]; then
    echolog "Service config: Enable gssm.service"
    systemctl enable w3p_gssm.service
    systemctl start w3p_gssm.service
  elif  [ "$(config_get gssm)" = "false" ]; then
    echolog "Service config: Disable w3p_gssm.service"
    systemctl disable w3p_gssm.service
  else
    echolog "Service config: NoChange w3p_gssm.service"
  fi

  if [ "$(config_get geth)" = "true" ]; then
    echolog "Service config: Enable w3p_geth.service"
    systemctl enable w3p_geth.service
    systemctl start w3p_geth.service
  elif  [ "$(config_get geth)" = "false" ]; then
    echolog "Service config: Disable w3p_geth.service"
    systemctl disable w3p_geth.service
  else
    echolog "Service config: NoChange w3p_geth.service"
  fi

  if [ "$(config_get lighthouse)" = "true" ]; then
    echolog "Service config: Enable w3p_lighthouse-beacon.service"
    systemctl enable w3p_lighthouse-beacon.service
    systemctl start w3p_lighthouse-beacon.service
  elif  [ "$(config_get lighthouse)" = "false" ]; then
    echolog "Service config: Disable w3p_lighthouse-beacon.service"
    systemctl disable w3p_lighthouse-beacon.service
  else
    echolog "Service config: NoChange w3p_lighthouse-beacon.service"
  fi


  if [ "$(config_get nimbus)" = "true" ]; then
    echolog "Service config: Enable w3p_nimbus-beacon.service"
    systemctl enable w3p_nimbus-beacon.service
    systemctl start w3p_nimbus-beacon.service
  elif  [ "$(config_get nimbus)" = "false" ]; then
    echolog "Service config: Disable w3p_nimbus-beacon.service"
    systemctl disable w3p_nimbus-beacon.service
  else
    echolog "Service config: NoChange w3p_nimbus-beacon.service"
  fi

  set_status "[install.sh] - Start and Enable unattended-upgrades.service"
  echolog "start unattended-upgrades.service"
  systemctl enable unattended-upgrades

fi


# Print the IP address
_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "\n\n\nRaspberry Pi IP address is %s\n\n\n" "$_IP"
fi

set_status "[install.sh] - End of script exit 0"
exit 0
