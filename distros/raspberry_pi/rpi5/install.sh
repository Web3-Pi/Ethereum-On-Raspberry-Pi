#!/bin/bash
#
# Web3Pi install script
#

SWAPFILE_SIZE=16384
DEV_NVME="/dev/nvme0n1"
DEV_USB="/dev/sda"
MIN_VALID_DISK_SIZE=$((50 * 1024 * 1024 * 1024))

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
  local retval=""

  if stat $DEV_NVME >/dev/null 2>&1; then
    retval=$DEV_NVME
  elif stat $DEV_USB >/dev/null 2>&1; then
    retval=$DEV_USB
  else
    echo "No suitable disk found"
    exit 1
  fi

  echo "$retval"
}

verify_size() {
  local part_size="$(lsblk -b -o NAME,SIZE | grep ${1:5})"
  local loc_array=($part_size)

  if [[ ${#loc_array[@]} != 2 ]]; then
    echo "Unexpected error while reading disk size"
    exit 1
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
      exit 1
    fi

    # Mount disk if it exists and is a Linux partition
    if  [[ -b "$PARTITION" && $(file -s "$PARTITION" | grep -oP 'Linux.*filesystem') ]]; then
      local TMP_DIR=$(mktemp -d)
      mount "$PARTITION" "$TMP_DIR"
    fi

    # Check if the path /home/ethereum exists on the mounted disk
    if [ -d "$TMP_DIR/ethereum" ]; then
      echo "/home/ethereum already exists on the disk."

      # Check if the .format_me file exists in the /home/ethereum path
      if [ -f "$TMP_DIR/ethereum/.format_me" ]; then
        echo "The .format_me file was found in /home/ethereum. Formatting and mounting..."
      else
        echo "The .format_me file was not found in /home/ethereum. Skipping formatting."
        proceed_with_format=false
      fi
    else
      echo "The path /home/ethereum does not exist on the disk. Formatting and mounting..."
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

  echo "Mounting $PARTITION as /home"
  echo "$PARTITION /home ext4 defaults,noatime 0 2" >> /etc/fstab && mount /home
}


# SCREEN CONFIGURATION

function add_user_screen_session() {
  local command=$1
  local session_name=$2
  local launch_script=$3

  # Ensure correctnes of the directory structure
  if [[ ! -d "$4" ]]; then
    sudo -u ethereum mkdir -p "$4"
  fi

  if [[ ! -d "$5" ]]; then
    sudo -u ethereum mkdir -p "$5"
  fi

  local script_dir="$(realpath $4)"
  local launch_dir="$(realpath $5)"

  local script_file="$script_dir/$session_name.sh"
  local launch_file="$launch_dir/$launch_script"

  # Change permissions and owner upon creation
  local launch_update_required=false

  if [[ -f "$launch_file" ]]; then
    launch_update_required=true
  fi

  # Amend sudo commands
  if [[ $# -gt 5 ]]; then
    echo -e "sudo $command" > "$script_file"

    # FIXME: hack - works only if session_name corresponds to an existing executable
    echo "ethereum ALL=(root) NOPASSWD: $(command -v $session_name)" > "/etc/sudoers.d/sudo-amend-$session_name"
  else
    echo -e "$command" > "$script_file"
  fi

  echo -e "screen -dmS $session_name\nscreen -S $session_name -X screen $script_file\n" >> "$launch_file"

  if [ $launch_update_required ]; then
    chmod +x "$launch_file"
    chown ethereum:ethereum "$launch_file"
  fi

  chmod +x "$script_file"
  chown ethereum:ethereum "$script_file"
}

function configure_monitoring_sessions() {
  local sdir="/home/ethereum/init/sessions"
  local ldir="/home/ethereum/init"
  local lf="screen.sh"

  # Sanity cleanup so that the commands are not duplicated
  local tf="$ldir/$lf"
  if [[ -f "$tf" ]]; then
    rm "$tf"
  fi

  # Add commands
  add_user_screen_session "watch -n 5 vcgencmd measure_temp" "temp" "$lf" "$sdir" "$ldir"
  add_user_screen_session "watch -n 5 vcgencmd measure_clock arm" "freq" "$lf" "$sdir" "$ldir"
  add_user_screen_session "iotop -oa -d 5" "iotop" "$lf" "$sdir" "$ldir" "amend_sudoer"
}

function configure_clients_sessions() {
  local sdir="/home/ethereum/clients"
  
  local geth_lf="screen-exec-cli.sh"
  local lighthouse_lf="screen-consensus-lighthouse-cli.sh"
  local nimbus_lf="screen-consensus-nimbus-cli.sh"

  # https://geth.ethereum.org/docs/fundamentals/command-line-options
  local geth_cmd="geth --authrpc.port=8551 --http --http.port 8545 --http.addr 0.0.0.0 --http.vhosts '*' --ws --ws.port 8546 --ws.addr 0.0.0.0 --ws.origins '*' --authrpc.jwtsecret /home/ethereum/clients/secrets/jwt.hex --state.scheme=path --discovery.port 30303 --port 30303"
  
  # https://lighthouse-book.sigmaprime.io/help_bn.html
  local lighthouse_cmd="lighthouse bn --network mainnet --execution-endpoint http://localhost:8551 --execution-jwt /home/ethereum/clients/secrets/jwt.hex --checkpoint-sync-url https://mainnet.checkpoint.sigp.io --disable-deposit-contract-sync --http --http-port 5052 --http-address=0.0.0.0 --port 9000"
  
  # https://nimbus.guide/options.html
  local nimbus_cmd="nimbus_beacon_node --network:mainnet --data-dir=/home/ethereum/.nimbus/data/shared_mainnet_0 --jwt-secret=/home/ethereum/clients/secrets/jwt.hex --el=http://127.0.0.1:8551 --tcp-port=9000 --udp-port=9000 --rest=true --rest-port=5052 --rest-address=0.0.0.0 --rest-allow-origin='*'"

 
  # Sanity cleanup so that the commands are not duplicated
  if [[ -f "$sdir/screen/$geth_lf" ]]; then
    rm "$sdir/screen/$geth_lf"
  fi

  if [[ -f "$sdir/screen/$lighthouse_lf" ]]; then
    rm "$sdir/screen/$lighthouse_lf"
  fi
  
  if [[ -f "$sdir/screen/$nimbus_lf" ]]; then
    rm "$sdir/screen/$nimbus_lf"
  fi

  # Prepare scripts and add sessions
  add_user_screen_session "$geth_cmd" "geth" "$geth_lf" "$sdir/geth" "$sdir/screen"
  add_user_screen_session "$lighthouse_cmd" "lighthouse" "$lighthouse_lf" "$sdir/lighthouse" "$sdir/screen"
  add_user_screen_session "$nimbus_cmd" "nimbus" "$nimbus_lf" "$sdir/nimbus" "$sdir/screen"
}


# MAIN 
FLAG="/root/first-run.flag"
if [ ! -f $FLAG ]; then
 
  
## 0. Add some necessary repositories ######################################################  
  echo "Adding Ethereum repositories"
  wget -q -O - http://apt.ethereumonarm.com/eoa.apt.keyring.gpg | tee /etc/apt/trusted.gpg.d/eoa.apt.keyring.gpg > /dev/null
  add-apt-repository -y -n "deb http://apt.ethereumonarm.com jammy main"
  
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
  apt-get -y install gdisk software-properties-common apt-utils file vim net-tools telnet apt-transport-https gcc jq

  
## 2. STORAGE SETUP ##########################################################################

  # Prepare drive to mount /home
  echo "Looking for a valid drive"
  DRIVE="$(get_best_disk)"

  echo "Preparing $DRIVE for installation"
  prepare_disk $DRIVE


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
  chage -d 0 ethereum


## 4. SWAP SPACE CONFIGURATION ###################################################################
  
  # Install dphys-swapfile package
  apt-get -y install dphys-swapfile

  # Configure swap file location and size
  sed -i "s|#CONF_SWAPFILE=.*|CONF_SWAPFILE=/home/ethereum/swapfile|" /etc/dphys-swapfile
  sed -i "s|#CONF_SWAPSIZE=.*|CONF_SWAPSIZE=$SWAPFILE_SIZE|" /etc/dphys-swapfile
  sed -i "s|#CONF_MAXSWAP=.*|CONF_MAXSWAP=$SWAPFILE_SIZE|" /etc/dphys-swapfile

  # Enable dphys-swapfile service
  systemctl enable dphys-swapfile
#  {
#    echo "vm.min_free_kbytes=65536"
#    echo "vm.swappiness=100"
#    echo "vm.vfs_cache_pressure=500"
#    echo "vm.dirty_background_ratio=1"
#    echo "vm.dirty_ratio=50"
#  } >> /etc/sysctl.conf
  
  echo "vm.swappiness=10" >>/etc/sysctl.conf  
  sysctl -p
  

## 5. ETHEREUM INSTALLATION #######################################################################
 
  # Ethereum software installation
  
  # Install Ethereum packages
  echo "Installing Ethereum packages"
  # Install Layer 1
  apt-get -y install geth lighthouse nimbus-beacon-node
  # Install validator clients
  #  apt-get -y install staking-deposit-cli nimbus-validator-client
  # install Layer 2
  # apt-get -y install arbitrum-nitro optimism-op-geth optimism-op-node polygon-bor polygon-heimdall starknet-juno


## 6. MISC CONF STEPS ##############################################################################

  # Install ufw
  apt-get -y install ufw
  ufw --force disable

  # Install some extra dependencies
  apt-get -y install libraspberrypi-bin iotop screen bpytop python3-dev libpython3.12-dev python3.12-venv

 
## 7. MONITORING ####################################################################################
 
  # Installing InfluxDB
  echo "Installing InfluxDB v1.8.10"
  dpkg -i /opt/web3pi/influxdb/influxdb_1.8.10_arm64.deb
  sed -i "s|# flux-enabled =.*|flux-enabled = true|" /etc/influxdb/influxdb.conf
  systemctl enable influxdb
  systemctl start influxdb
  sleep 5
  influx -execute 'CREATE DATABASE ethonrpi'
  influx -execute "CREATE USER geth WITH PASSWORD 'geth'"
  
  # Installing Grafana
  echo "Installing Grafana"
  apt-get install -y grafana

  # Copy datasources.yaml for grafana
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/rpi5/grafana/yaml/datasources.yaml /etc/grafana/provisioning/datasources/datasources.yaml

  # Copy dashboards.yaml for grafana
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/rpi5/grafana/yaml/dashboards.yaml /etc/grafana/provisioning/dashboards/dashboards.yaml
  
  # Copy dashboard_Web3Pi.json for grafana
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/rpi5/grafana/yaml/node_monitoring.json /home/ethereum/clients/grafana/dashboards/node_monitoring.jso
  chmod 744 /home/ethereum/clients/grafana/dashboards/node_monitoring.jso
  
 
  systemctl enable grafana-server
  systemctl start grafana-server
 
 
  # BASIC SCREEN-BASED MONITORING
  #echo "Configuring monitoring scripts and screen sessions"
  #configure_monitoring_sessions

## 8. SERVICES CONFIGURATION ###########################################################################

  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/rpi5/bsm/w3p_bsm.service /etc/systemd/system/w3p_bsm.service
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/rpi5/bnm/w3p_bnm.service /etc/systemd/system/w3p_bnm.service
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/rpi5/geth/w3p_geth.service /etc/systemd/system/w3p_geth.service
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/rpi5/lighthouse/w3p_lighthouse-beacon.service /etc/systemd/system/w3p_lighthouse-beacon.service
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/rpi5/nimbus/w3p_nimbus-beacon.service /etc/systemd/system/w3p_nimbus-beacon.service


## 9. CLIENTS CONFIGURATION ############################################################################

  #echo "Configuring clients screen sessions"
  #configure_clients_sessions
  
  echo "Configuring clients run scripts"
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/rpi5/geth/geth.sh /home/ethereum/clients/geth/geth.sh
  chmod +x /home/ethereum/clients/geth/geth.sh
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/rpi5/lighthouse/lighthouse.sh /home/ethereum/clients/lighthouse/lighthouse.sh
  chmod +x /home/ethereum/clients/lighthouse/lighthouse.sh
  cp /opt/web3pi/Ethereum-On-Raspberry-Pi/distros/raspberry_pi/rpi5/nimbus/nimbus.sh /home/ethereum/clients/nimbus/nimbus.sh
  chmod +x /home/ethereum/clients/nimbus/nimbus.sh

## 10. ADDITIONAL DIRECTORIES ###########################################################################
  echo "Adding client directories required to run the node"
  sudo -u ethereum mkdir -p /home/ethereum/clients/secrets
  sudo -u ethereum openssl rand -hex 32 | tr -d "\n" | tee /home/ethereum/clients/secrets/jwt.hex
  echo " "


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

  # Delete ubuntu user
  deluser ubuntu

  # Delete raspberry user
  deluser raspberry


## 13. READ CONFIG FROM CONFIG.TXT ########################################################################

# Read custom settings from /boot/firmware/config.txt - [Web3Pi] tag
  echo "Read custom settings from /boot/firmware/config.txt - [Web3Pi] tag" 
  
  if [ "$(config_get bsm)" = "true" ]; then
    echo "Service config: Enable w3p_bsm.service"
    systemctl enable w3p_bsm.service
  # systemctl start w3p_bsm.service
  else
    echo "Service config: Disable w3p_bsm.service"
    systemctl disable w3p_bsm.service
  fi

  if [ "$(config_get bnm)" = "true" ]; then
    echo "Service config: Enable w3p_bnm.service"
    systemctl enable w3p_bnm.service
  # systemctl start w3p_bnm.service
  else
    echo "Service config: Disable w3p_bnm.service"
    systemctl disable w3p_bnm.service
  fi
  
  if [ "$(config_get geth)" = "true" ]; then
    echo "Service config: Enable w3p_geth.service"
    systemctl enable w3p_geth.service
  # systemctl start w3p_geth.service
  else
    echo "Service config: Disable w3p_geth.service"
    systemctl disable w3p_geth.service
  fi

  if [ "$(config_get lighthouse)" = "true" ]; then
    echo "Service config: Enable w3p_lighthouse-beacon.service"
    systemctl enable w3p_lighthouse-beacon.service
  # systemctl start w3p_lighthouse-beacon.service
  else
    echo "Service config: Disable w3p_lighthouse-beacon.service"
    systemctl disable w3p_lighthouse-beacon.service
  fi

  if [ "$(config_get nimbus)" = "true" ]; then
    echo "Service config: Enable w3p_nimbus-beacon.service"
    systemctl enable w3p_nimbus-beacon.service
  # systemctl start w3p_nimbus-beacon.service
  else
    echo "Service config: Disable w3p_nimbus-beacon.service"
    systemctl disable w3p_nimbus-beacon.service
  fi


  

  #the next line creates an empty file so it won't run the next boot
  touch $FLAG
  grep "rc.local" /var/log/syslog >> $FLAG
  
  echo "Rebooting..."
  reboot
else
  echo "Setting up screen sessions"
  sudo -u ethereum /home/ethereum/init/screen.sh
fi


# Print the IP address
_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "\n\n\nMy IP address is %s\n\n\n" "$_IP"
fi


exit 0
