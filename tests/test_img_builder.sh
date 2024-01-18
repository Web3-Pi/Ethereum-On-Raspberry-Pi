IMG_FILE="test_image.img"
SIZE_IN_BYTES=$(( 4 * 1024 * 1024 ))
SIZE_HUMAN_READABLE=$(numfmt --to=iec-i --suffix=B --format='%.1f' $SIZE_IN_BYTES)


# GENERIC FUNCTIONS

function configure_tools() {
  echo "Configuring required tools"
  echo "  -> kpartx"

  if ! command -v kpartx &> /dev/null; then
    sudo apt update
    echo "  -> kpartx not found - installing"
    sudo apt install kpartx
  else
    echo "  -> kpartx alread installed"
  fi
}


# DISK SETUP

function create_empty_file() {
  local img_file=$1
  local size_in_bytes=$2

  # Create an empty file (filled with zeros)
  echo "  -> creating an empty file ${img_file}"
  if [[ -f $img_file ]]; then
    echo "  -> removing old file $img_file"
    rm "$img_file"
  fi
  dd if=/dev/zero of=${img_file} bs=512 count=$(( $size_in_bytes / 512 ))
}

function create_loop_dev() {
  local img_file=$1

  sudo losetup -f ${img_file}
  local loop_dev=$(sudo losetup -j ${img_file} | grep -o "/dev/loop[0-9]*")

  echo "${loop_dev}"
}

function configure_partitions() {
  local img_file=$1

  # Access the file as loop device
  echo "Setting up loop device"
  local loop_dev=$(create_loop_dev ${img_file})
  echo "  -> using $loop_dev"

  # Configure parition table and paritions
  echo "Configuring paritions"
  local disk_info=$(sudo sgdisk -p ${loop_dev})

  # local sec_start=$(echo $disk_info | grep -o "First usable sector is [0-9]*" | grep -o "[0-9]*")
  # local sec_start=2048
  # local sec_end=$(echo $disk_info | grep -o ", last usable sector is [0-9]*" | grep -o "[0-9]*")
  # local sec_end_p1=$(( ($sec_end - $sev_startt) / 2))
  # local sec_start_p2=$(( $sec_end_P1 + 1 ))
  #sudo sgdisk -n 0:$sec_start:$sec_end_p1 -t 0:ea00 -c 0:boot "$loop_dev"
  #sudo sgdisk -n 1:$sec_start_p2:$sec_end -t 0:8300 -c 0:root "$loop_dev"

  # Set up partitions using sgdisk
  echo "  -> Setting up P1"
  sudo sgdisk -n 0:0:+500KiB -t 0:ea00 -c 0:boot "$loop_dev"

  echo "  -> Setting up P2"
  sudo sgdisk -n 0:0:+1MiB -t 0:8300 -c 0:root "$loop_dev"

  # Write parition table by releasing loop device
  echo "Writing paritions"
  echo "  -> ${loop_dev}p1"
  echo "  -> ${loop_dev}p2"
  sudo losetup -d ${loop_dev}
}

function configure_fs() {
  local img_file=$1
  local loop_dev=$(create_loop_dev ${img_file})

  # Format the second partion (ext4)
  echo "Formatting second partition"
  local partition="/dev/mapper/$(echo ${loop_dev} | grep -o 'loop[0-9]*')p2"
  sudo kpartx -v -a "$loop_dev"
  echo "  -> mkfs.ext4 $partition"
  sudo mkfs.ext4 ${partition}

  # Add necessary directories to the partition
  echo "Adding /etc to the filesystem"
  local tmp_dir=$(mktemp -d)
  echo "  -> mounting partition to $tmp_dir"
  sudo mount ${partition} ${tmp_dir}
  echo "  -> creating /etc directory"
  sudo mkdir "${tmp_dir}/etc"
  sudo chown root:root "${tmp_dir}/etc"

  # Release resources
  echo "Cleaning up"
  echo "  -> umounting ${tmp_dir}"
  sudo umount ${tmp_dir}
  sudo rmdir ${tmp_dir}

  echo "  -> removing mapped loop partitions"
  sudo kpartx -v -d ${loop_dev}

  echo "  -> removing loop device"
  sudo losetup -d ${loop_dev}
}


# MAIN

# Configure environement
configure_tools

# Create template file
echo "Preparig empty image file: $IMG_FILE, size: $SIZE_HUMAN_READABLE"
create_empty_file $IMG_FILE $SIZE_IN_BYTES

# Configure parititions
configure_partitions $IMG_FILE

# Configure filesystem
configure_fs $IMG_FILE

# Print a colored result
light_green='\033[1;32m'
nc='\033[0m'
echo -e "Test image ${light_green}${IMG_FILE}${nc} configured successfully"
