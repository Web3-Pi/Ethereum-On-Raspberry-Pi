#!/bin/bash
#
# img_builder.sh
#
# This script is used to create a valid ethereum-on-pi image
# file for Raspberry Pi 4 Model B
#


# Static setup
DEFAULT_RES_IMG_NAME="ethereumonpi_22.04.00.img"
EOA_IMG_NAME="ethonarm_22.04.00.img.zip"
EOA_IMG="ethonarm_22.04.00.img"
EOA_RPI4_IMG_URL="https://ethereumonarm-my.sharepoint.com/:u:/p/dlosada/Ec_VmUvr80VFjf3RYSU-NzkBmj2JOteDECj8Bibde929Gw?download=1"
REL_RC_LOCAL="../../../../distros/raspberry_pi/rpi4/templates/etc/rc.local"

# To be set during the initial setup phase
RC_LOCAL_FILE=""
OUTPUT_IMAGE_FILE=""


# GENERIC

function configure_tools() {
  local commands="kpartx zip pv unzip"
  local command=$1
  local apt_updated=false

  echo "Configuring tools"

  for cmd in $commands; do
    if ! command -v "$cmd" &> /dev/null; then
      if ! $apt_updated; then
        sudo apt update
        apt_updated=true
      fi

      echo "  -> $cmd not found - installing"
      sudo apt install "$cmd"
    else
      echo "  -> $cmd already installed"
    fi
  done
}


# INPUT PROCESSINIG

function get_rc_local() {
  if [[ ! -f "$PWD/$REL_RC_LOCAL" ]]; then
    echo "Ethereum-on-Pi rc.local template not available"
    exit 1
  fi

  echo "$(realpath $PWD/$REL_RC_LOCAL)"
}

function usage () {
  echo "Usage: $(basename $0) [-i input_image_file] [-r rc.local template location] [-o output_file] | -h"
}

function setup_execution() {
  local remove_input=true
  local OPTIND opt

  # Read input arguments
  while getopts ":i:o:r:h" opt; do
    case "$opt" in
      i) local remove_input=false
         local input_file=${OPTARG}
         ;;

      o) local output_file=${OPTARG}
         ;;

      r) local rc_local_file=${OPTARG}
         ;;

      h) usage
         exit 1
         ;;

      :) echo -e "Option requires argument"
         usage
         exit 1
         ;;

      ?) echo "Invalid commad option"
         usage
         exit 1
         ;;

    esac
  done
  shift $((OPTIND-1))

  echo "Setting up execution environement from the input arguments"
  configure_tools

  # Assign an input rc.local template
  if [[ -z "${rc_local_file}" ]]; then
    rc_local_file="$(get_rc_local)"
    echo -e "Init script template not specified\n  -> falling back to the default template: $rc_local_file"
  else
    if [[ ! -f "${rc_local_file}" ]]; then
      echo "Provided init script template: ${rc_local_file} does not exist"
      exit 1
    fi

    echo -e "Init script template provided by user\n  -> ${rc_local_file}"
  fi

  # Make sure that the output file is specified and strip last ".zip" if exists
  if [[ -z "${output_file}" ]]; then
    echo -e "Output file not specified\n  -> falling back the default name: $DEFAULT_RES_IMG_NAME"
    output_file="$DEFAULT_RES_IMG_NAME"
  else
    if [[ "${output_file}" = *.zip ]]; then
      output_file="$(dirname ${output_file})/$(basename ${output_file} .zip)"
    fi

    echo -e "Output file provided by user\n  -> ${output_file}"
  fi

  # Assign or download source EOA image
  if [[ ! -z "$input_file" ]]; then
    if [[ ! -f "$input_file" ]]; then
      echo "Input filename specified: $input_file, but the corresponding file does not exist"
      exit 1
    fi

    echo -e "Input image provided by user\n  -> ${input_file}"
  else
    echo -e "Input file not specified\n  -> moving forward with $EOA_IMG_NAME from the Ethereum on ARM repository"
    wget -O "$EOA_IMG_NAME" "$EOA_RPI4_IMG_URL"

    local file_size=($(ls -alh $EOA_IMG_NAME | grep $EOA_IMG_NAME))
    file_size=${file_size[4]}

    echo "Unzipping file: $EOA_IMG_NAME, size: $file_size"
    unzip "$EOA_IMG_NAME"

    echo "Removing $EOA_IMG_NAME"
    rm "$EOA_IMG_NAME"

    input_file="$EOA_IMG"
  fi

  # Handle names of the input and output files
  input_file="$(realpath ${input_file})"
  output_file="$(realpath ${output_file})"

  if $remove_input; then
    if [[ "${input_file}" != "${output_file}" ]]; then
      echo "  -> moving ${input_file} to ${output_file}"
      mv "${input_file}" "${output_file}"
    fi
  else
    if [[ "${input_file}" == "${output_file}" ]]; then
      local dn=$(dirname "${output_file}")
      local fn=$(basename "${output_file}")
      output_file="${dn}/result-${fn}"
    fi

    echo "  -> copying ${input_file} to ${output_file}"
    pv "${input_file}" > "${output_file}"
  fi

  OUTPUT_IMAGE_FILE="${output_file}"
  RC_LOCAL_FILE="$(realpath ${rc_local_file})"
}


# IMAGE PROCESSING

function map_image() {
  local FILE=$1

  if [[ ! -f $FILE ]]; then
    echo "$FILE does not exist"
    exit 1
  fi

  if [[ ! -z "$(sudo kpartx -l $FILE 2>&1 | grep -oP 'error')" ]]; then
    echo "$FILE is not a valid image file"
    exit 1
  fi

  local DEVICES=($(sudo kpartx -av $FILE | grep -oP "\bloop\w+"))
  if [[ ${#DEVICES[@]} != 2 ]]; then
    echo "Invalid number of partitions found. Expected 2, provided ${#DEVICES[@]}"
    echo "-- ${DEVICES[@]}"
    sudo kpartx -d $FILE
    exit 1
  fi

  echo "/dev/mapper/${DEVICES[1]}"
}

function prepare_image() {
  local rc_local_file=$1
  local output_file=$2

  # Verify and map image file
  echo "Verifing and mapping image file $output_file to a loop device"
  local dev=$(map_image $output_file)
  echo "  -> $dev (OS partition)"

  # Mount temp dir with the mapped parition
  local tmp_dir=$(mktemp -d)
  sudo mount "$dev" "$tmp_dir"
  if [[ ! -d "$tmp_dir/etc" ]]; then
    echo "Image does not contain /etc directory"

    sudo umount "$tmp_dir"
    rm -r "$tmp_dir"
    sudo kpartx -d "$output_file"

    exit 0
  fi

  # Write rc.local to mapped partition
  echo "Partition mounted to a temporary directory"
  echo "  -> $tmp_dir"

  echo "Writing $rc_local_file to the image"
  echo "  -> sudo cp $rc_local_file $tmp_dir/etc/rc.local"
  sudo cp "$rc_local_file" "$tmp_dir/etc/rc.local"
  sudo chown root:root "$tmp_dir/etc"
  sudo chown root:root "$tmp_dir/etc/rc.local"

  # Cleaning up
  echo "Releasing resources"

  echo "  -> $tmp_dir"
  sudo umount "$tmp_dir"
  rm -r "$tmp_dir"

  echo "  -> $dev"
  sudo kpartx -dv "$output_file"

  # Preparing final image
  echo "Creating zip archive from the image file"
  echo "  -> $output_file.zip"
  zip -jr "$output_file.zip" "$output_file"

  # Final cleanup
  echo "Removing temporary image file"
  echo "  -> $output_file"
  rm "$output_file"

  # OUTPUT
  local light_green='\033[1;32m'
  local nc='\033[0m'
  echo "Image file generated successfully"
  echo -e "  -> result: ${light_green}$(basename $output_file).zip${nc}"
  echo -e "  -> location: ${output_file}.zip"
}


# MAIN

setup_execution "$@"

echo "Preparing image"
prepare_image $RC_LOCAL_FILE $OUTPUT_IMAGE_FILE
