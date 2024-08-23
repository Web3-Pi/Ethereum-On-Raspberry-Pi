#!/bin/bash
#
# Web3Pi install script
#

SWAPFILE_SIZE=16384
DEV_NVME="/dev/nvme0n1"
DEV_USB="/dev/sda"
W3P_DRIVE="NA"
MIN_VALID_DISK_SIZE=$((150 * 1024 * 1024 * 1024))
FLAG="/root/first-run.flag"
RFLAG="/root/rflag.flag"
ELOG="/root/elog.txt"

# Terminate the script with saving logs
terminateScript()
{
  echo "terminateScript()"
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
    echo "No suitable disk found"
    terminateScript
    #kill -9 $$
  fi
}

verify_size() {
  local part_size="$(lsblk -b -o NAME,SIZE | grep ${1:5})"
  local loc_array=($part_size)

  if [[ ${#loc_array[@]} != 2 ]]; then
    echo "Unexpected error while reading disk size"
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
    echo "$DISK contains $num_of_partitions partitions (exactly one allowed). Formating."
  else
    # Verify that the provided disk is large enough to store at least part of the swap file and least significant part of consensus client state 
    if ! verify_size $PARTITION; then
      echo "Disk to small to proceed with installation"
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
      echo ".ethereum already exists on the disk."

      # Check if the .format_me file exists in the .ethereum path
      if [ -f "$TMP_DIR/.format_me" ]; then
        echo "The .format_me file was found. Formatting and mounting..."
      else
        echo "The .format_me file was not found. Skipping formatting."
        proceed_with_format=false
      fi
    else
      echo "The .ethereum does not exist on the disk. Formatting and mounting..."
    fi

    # Unmount the disk from the temporary directory
    if mountpoint -q "$TMP_DIR"; then
      umount "$TMP_DIR"
      rm -r "$TMP_DIR"
    fi
  fi

  if [ "$proceed_with_format" = true ]; then
    # Create a new partition and format it as ext4
    echo "Creating new partition and formatting disk: $DISK..."
    wipefs -a "$DISK"
    sgdisk -n 0:0:0 "$DISK"
    mkfs.ext4 -F "$PARTITION" || {
      echo "Unable to format $PARTITION"
      return 1
    }

    echo "Removing FS reserved blocks on partion $PARTITION"
    tune2fs -m 0 $PARTITION
  fi

  echo "Mounting $PARTITION as /mnt/storage"
  echo "$PARTITION /mnt/storage ext4 defaults,noatime 0 2" >> /etc/fstab && mount /mnt/storage
}


# MAIN 

if [ ! -f $FLAG ]; then

  echo "stop unattended-upgrades.service"
  systemctl stop unattended-upgrades
  systemctl disable unattended-upgrades

  # Firmware update
  if [ ! -f $RFLAG ]; then
    echo "rpi-eeprom-update -a"
    sudo rpi-eeprom-update -a
    touch $RFLAG
    echo "RFLAG created"
    echo "Rebooting after rpi-eeprom-update"
    #sleep 3
    reboot
    exit 1
  fi

  
## 0. Add some necessary repositories ######################################################  
  echo "Adding Ethereum repositories"
  sudo add-apt-repository -y ppa:ethereum/ethereum
  
  echo "Adding nimbus repositories"
  echo 'deb https://apt.status.im/nimbus all main' | tee /etc/apt/sources.list.d/nimbus.list
  # Import the GPG key
  curl https://apt.status.im/pubkey.asc -o /etc/apt/trusted.gpg.d/apt-status-im.asc

  echo "Adding Grafana repositories"
  wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
  echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | tee -a /etc/apt/sources.list.d/grafana.list
  

## 1. Install some required dependencies ####################################################
 
  echo "Installing required dependencies"
  apt-get update
  apt-get -y install gdisk software-properties-common apt-utils file vim net-tools telnet apt-transport-https gcc jq chrony

  
## 2. STORAGE SETUP ##########################################################################

  # Prepare drive to mount /mnt/storage
  echo "Looking for a valid drive"
  get_best_disk
  echo "W3P_DRIVE=$W3P_DRIVE"

  echo "Preparing $W3P_DRIVE for installation"
  prepare_disk $W3P_DRIVE


## 3. ACCOUNT CONFIGURATION ###################################################################

  # Create Ethereum account
  echo "Creating ethereum user"
  if ! id -u ethereum >/dev/null 2>&1; then
    adduser --disabled-password --gecos "" ethereum
  fi

  echo "ethereum:ethereum" | chpasswd
  for GRP in sudo netdev audio video dialout plugdev; do
    adduser ethereum $GRP
  done

  # Force password change on first login
  #chage -d 0 ethereum


## 4. SWAP SPACE CONFIGURATION ###################################################################
  
  # Install dphys-swapfile package
  apt-get -y install dphys-swapfile

  # Configure swap file location and size
  sed -i "s|#CONF_SWAPFILE=.*|CONF_SWAPFILE=/mnt/storage/swapfile|" /etc/dphys-swapfile
  sed -i "s|#CONF_SWAPSIZE=.*|CONF_SWAPSIZE=$SWAPFILE_SIZE|" /etc/dphys-swapfile
  sed -i "s|#CONF_MAXSWAP=.*|CONF_MAXSWAP=$SWAPFILE_SIZE|" /etc/dphys-swapfile

  # Enable dphys-swapfile service
  systemctl enable dphys-swapfile
  {
    echo "vm.min_free_kbytes=65536"
    echo "vm.swappiness=100"
    echo "vm.vfs_cache_pressure=500"
    echo "vm.dirty_background_ratio=1"
    echo "vm.dirty_ratio=50"
  } >> /etc/sysctl.conf
  
#  echo "vm.swappiness=10" >>/etc/sysctl.conf  
#  sysctl -p
  

## 5. ETHEREUM INSTALLATION #######################################################################
 
  # Ethereum software installation
  
  # Install Ethereum packages
  echo "Installing Ethereum packages"
  # Install Layer 1
  apt-get -y install geth nimbus-beacon-node
  
 
  LH_RELEASE_URL="https://api.github.com/repos/sigp/lighthouse/releases/latest"
  LH_BINARIES_URL="$(curl -s $LH_RELEASE_URL | jq -r ".assets[] | select(.name) | .browser_download_url" | grep aarch64-unknown-linux-gnu.tar.gz$)"

  echo Downloading Lighthouse URL: $LH_BINARIES_URL

  # Download
  wget -O /tmp/lighthouse.tar.gz $LH_BINARIES_URL
  # Untar
  tar -xzvf /tmp/lighthouse.tar.gz -C /tmp/
  # Cleanup
  rm /tmp/lighthouse.tar.gz

  cp /tmp/lighthouse /usr/bin

  lighthouse --version

## 6. MISC CONF STEPS ##############################################################################

  # Install ufw
  apt-get -y install ufw
  ufw --force disable

  # Install some extra dependencies
  apt-get -y install libraspberrypi-bin iotop screen bpytop python3-dev libpython3.12-dev python3.12-venv

 
## 7. MONITORING ####################################################################################

  #echo "stop unattended-upgrades.service"
  #systemctl stop unattended-upgrades
  
  # Installing InfluxDB
  echo "Installing InfluxDB v1.8.10"
  dpkg -i /opt/web3pi/influxdb/influxdb_1.8.10_arm64.deb
  sed -i "s|# flux-enabled =.*|flux-enabled = true|" /etc/influxdb/influxdb.conf
#  systemctl enable influxdb
  systemctl start influxdb
  sleep 5
  influx -execute 'CREATE DATABASE ethonrpi'
  influx -execute "CREATE USER geth WITH PASSWORD 'geth'"
  
  # Installing Grafana
  echo "Installing Grafana"
  apt-get install -y grafana

  # Copy datasources.yaml for grafana
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/grafana/yaml/datasources.yaml /etc/grafana/provisioning/datasources/datasources.yaml

  # Copy dashboards.yaml for grafana
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/grafana/yaml/dashboards.yaml /etc/grafana/provisioning/dashboards/dashboards.yaml

 
#  systemctl enable grafana-server
  systemctl start grafana-server
 

## 8. SERVICES CONFIGURATION ###########################################################################

  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/bsm/w3p_bsm.service /etc/systemd/system/w3p_bsm.service
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/bnm/w3p_bnm.service /etc/systemd/system/w3p_bnm.service
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/geth/w3p_geth.service /etc/systemd/system/w3p_geth.service
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/lighthouse/w3p_lighthouse-beacon.service /etc/systemd/system/w3p_lighthouse-beacon.service
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/nimbus/w3p_nimbus-beacon.service /etc/systemd/system/w3p_nimbus-beacon.service


## 9. CLIENTS CONFIGURATION ############################################################################
  
  echo "Configuring clients run scripts"
  sudo -u ethereum mkdir -p /home/ethereum/clients/geth
  sudo -u ethereum mkdir -p /home/ethereum/clients/lighthouse
  sudo -u ethereum mkdir -p /home/ethereum/clients/nimbus
  
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/geth/geth.sh /home/ethereum/clients/geth/geth.sh
  chmod +x /home/ethereum/clients/geth/geth.sh
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/lighthouse/lighthouse.sh /home/ethereum/clients/lighthouse/lighthouse.sh
  chmod +x /home/ethereum/clients/lighthouse/lighthouse.sh
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/nimbus/nimbus.sh /home/ethereum/clients/nimbus/nimbus.sh
  chmod +x /home/ethereum/clients/nimbus/nimbus.sh


  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/bsm/run.sh /opt/web3pi/basic-system-monitor/run.sh
  chmod +x /opt/web3pi/basic-system-monitor/run.sh

  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/bnm/run.sh /opt/web3pi/basic-eth2-node-monitor/run.sh
  chmod +x /opt/web3pi/basic-eth2-node-monitor/run.sh

## 10. ADDITIONAL DIRECTORIES ###########################################################################
  echo "Adding client directories required to run the node"
  sudo -u ethereum mkdir -p /home/ethereum/clients/secrets/
  #sudo -u ethereum openssl rand -hex 32 | tr -d "\n" | tee /home/ethereum/clients/secrets/jwt.hex
  sudo -u ethereum openssl rand -hex 32 | sudo -u ethereum tr -d "\n" | sudo -u ethereum tee /home/ethereum/clients/secrets/jwt.hex
  echo " "

  ln -s /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/scripts/ /home/ethereum/
  chmod +x /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/scripts/*.sh

## 11. CONVENIENCE CONFIGURATION ########################################################################

  # Force colored prompt
  echo "Setting up a colored prompt"
  if [[ ! -f "/home/ethereum/.bashrc" ]]; then
    cp /etc/skel/.bashrc /home/ethereum
  fi

  sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/ethereum/.bashrc
  chown ethereum:ethereum /home/ethereum/.bashrc

  echo "basic-system-monitor venv conf"
  cd /opt/web3pi/basic-system-monitor
  python3 -m venv venv

  chmod +x /opt/web3pi/basic-system-monitor/run.sh
  
  echo "basic-eth2-node-monitor venv conf"
  cd /opt/web3pi/basic-eth2-node-monitor
  python3 -m venv venv

  chmod +x /opt/web3pi/basic-eth2-node-monitor/run.sh


## 12. CLEANUP ###########################################################################################

  # RPi imager fix
  chown root:root /etc

  # Disable root user
  passwd -l root

  # Delete raspberry user
  deluser raspberry


## 13. READ CONFIG FROM CONFIG.TXT ########################################################################

# Read custom settings from /boot/firmware/config.txt - [Web3Pi] tag
  echo "Read custom settings from /boot/firmware/config.txt - [Web3Pi] tag" 

  if [ "$(config_get influxdb)" = "true" ]; then
    echo "Service config: Enable influxdb.service"
    systemctl enable influxdb.service
#    systemctl start influxdb.service
  elif  [ "$(config_get influxdb)" = "false" ]; then
    echo "Service config: Disable influxdb.service"
    systemctl disable influxdb.service
  else
    echo "Service config: NoChange influxdb.service"
  fi

  if [ "$(config_get grafana)" = "true" ]; then
    echo "Service config: Enable grafana-server.service"
    systemctl enable grafana-server.service
 #   systemctl start grafana-server.service
  elif  [ "$(config_get grafana)" = "false" ]; then
    echo "Service config: Disable grafana-server.service"
    systemctl disable grafana-server.service
  else
    echo "Service config: NoChange grafana-server.service"
  fi
 
  if [ "$(config_get bsm)" = "true" ]; then
    echo "Service config: Enable w3p_bsm.service"
    systemctl enable w3p_bsm.service
  # systemctl start w3p_bsm.service
  elif  [ "$(config_get bsm)" = "false" ]; then
    echo "Service config: Disable w3p_bsm.service"
    systemctl disable w3p_bsm.service
  else
    echo "Service config: NoChange w3p_bsm.service"
  fi

  if [ "$(config_get bnm)" = "true" ]; then
    echo "Service config: Enable w3p_bnm.service"
    systemctl enable w3p_bnm.service
  # systemctl start w3p_bnm.service
  elif  [ "$(config_get bnm)" = "false" ]; then
    echo "Service config: Disable w3p_bnm.service"
    systemctl disable w3p_bnm.service
  else
    echo "Service config: NoChange w3p_bnm.service"
  fi

  if [ "$(config_get geth)" = "true" ]; then
    echo "Service config: Enable w3p_geth.service"
    systemctl enable w3p_geth.service
  # systemctl start w3p_geth.service
  elif  [ "$(config_get geth)" = "false" ]; then
    echo "Service config: Disable w3p_geth.service"
    systemctl disable w3p_geth.service
  else
    echo "Service config: NoChange w3p_geth.service"
  fi

  if [ "$(config_get lighthouse)" = "true" ]; then
    echo "Service config: Enable w3p_lighthouse-beacon.service"
    systemctl enable w3p_lighthouse-beacon.service
  # systemctl start w3p_lighthouse-beacon.service
  elif  [ "$(config_get lighthouse)" = "false" ]; then
    echo "Service config: Disable w3p_lighthouse-beacon.service"
    systemctl disable w3p_lighthouse-beacon.service
  else
    echo "Service config: NoChange w3p_lighthouse-beacon.service"
  fi


  if [ "$(config_get nimbus)" = "true" ]; then
    echo "Service config: Enable w3p_nimbus-beacon.service"
    systemctl enable w3p_nimbus-beacon.service
  # systemctl start w3p_nimbus-beacon.service
  elif  [ "$(config_get nimbus)" = "false" ]; then
    echo "Service config: Disable w3p_nimbus-beacon.service"
    systemctl disable w3p_nimbus-beacon.service
  else
    echo "Service config: NoChange w3p_nimbus-beacon.service"
  fi
  


  #the next line creates an empty file so it won't run the next boot
  touch $FLAG
  grep "rc.local" /var/log/syslog >> $FLAG
  
  echo "Rebooting..."
  reboot
else

  # Read custom settings from /boot/firmware/config.txt - [Web3Pi] tag
  echo "Read custom settings from /boot/firmware/config.txt - [Web3Pi] tag" 

  if [ "$(config_get influxdb)" = "true" ]; then
    echo "Service config: Enable influxdb.service"
    systemctl enable influxdb.service
    systemctl start influxdb.service
  elif  [ "$(config_get influxdb)" = "false" ]; then
    echo "Service config: Disable influxdb.service"
    systemctl disable influxdb.service
  else
    echo "Service config: NoChange influxdb.service"
  fi

  if [ "$(config_get grafana)" = "true" ]; then
    echo "Service config: Enable grafana-server.service"
    systemctl enable grafana-server.service
    systemctl start grafana-server.service
  elif  [ "$(config_get grafana)" = "false" ]; then
    echo "Service config: Disable grafana-server.service"
    systemctl disable grafana-server.service
  else
    echo "Service config: NoChange grafana-server.service"
  fi
  
  if [ "$(config_get bsm)" = "true" ]; then
    echo "Service config: Enable w3p_bsm.service"
    systemctl enable w3p_bsm.service
    systemctl start w3p_bsm.service
  elif  [ "$(config_get bsm)" = "false" ]; then
    echo "Service config: Disable w3p_bsm.service"
    systemctl disable w3p_bsm.service
  else
    echo "Service config: NoChange w3p_bsm.service"
  fi

  if [ "$(config_get bnm)" = "true" ]; then
    echo "Service config: Enable w3p_bnm.service"
    systemctl enable w3p_bnm.service
    systemctl start w3p_bnm.service
  elif  [ "$(config_get bnm)" = "false" ]; then
    echo "Service config: Disable w3p_bnm.service"
    systemctl disable w3p_bnm.service
  else
    echo "Service config: NoChange w3p_bnm.service"
  fi

  if [ "$(config_get geth)" = "true" ]; then
    echo "Service config: Enable w3p_geth.service"
    systemctl enable w3p_geth.service
    systemctl start w3p_geth.service
  elif  [ "$(config_get geth)" = "false" ]; then
    echo "Service config: Disable w3p_geth.service"
    systemctl disable w3p_geth.service
  else
    echo "Service config: NoChange w3p_geth.service"
  fi

  if [ "$(config_get lighthouse)" = "true" ]; then
    echo "Service config: Enable w3p_lighthouse-beacon.service"
    systemctl enable w3p_lighthouse-beacon.service
    systemctl start w3p_lighthouse-beacon.service
  elif  [ "$(config_get lighthouse)" = "false" ]; then
    echo "Service config: Disable w3p_lighthouse-beacon.service"
    systemctl disable w3p_lighthouse-beacon.service
  else
    echo "Service config: NoChange w3p_lighthouse-beacon.service"
  fi


  if [ "$(config_get nimbus)" = "true" ]; then
    echo "Service config: Enable w3p_nimbus-beacon.service"
    systemctl enable w3p_nimbus-beacon.service
    systemctl start w3p_nimbus-beacon.service
  elif  [ "$(config_get nimbus)" = "false" ]; then
    echo "Service config: Disable w3p_nimbus-beacon.service"
    systemctl disable w3p_nimbus-beacon.service
  else
    echo "Service config: NoChange w3p_nimbus-beacon.service"
  fi

  echo "start unattended-upgrades.service"
  systemctl enable unattended-upgrades

fi


# Print the IP address
_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "\n\n\nRaspberry Pi IP address is %s\n\n\n" "$_IP"
fi


exit 0