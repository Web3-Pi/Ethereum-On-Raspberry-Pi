#!/bin/bash
#
# rc_local_editor.sh
#
# This script is used to update the contents of rc.local in an existing
# image file (to be used with Raspberry Pi 4 or CM4)
#

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <img file>"
  exit 0
fi

FILE=$1

if ! command -v kpartx &> /dev/null; then
  echo "kpartx not found - installing"
  sudo apt update
  sudo apt install kpartx
fi

echo "Verifying $FILE"

if [[ ! -f $FILE ]]; then
  echo "$FILE is not a valid file"
  exit 0
fi

if [[ ! -z "$(sudo kpartx -l $FILE 2>&1 | grep -oP 'error')" ]]; then
  echo "$FILE is not a valid image file"
  exit 0
fi

echo "Verification succesfull"
echo "Mounting $FILE as a loop device(s)"

DEVICES=($(sudo kpartx -av $FILE | grep -oP "\bloop\w+"))
if [[ ${#DEVICES[@]} != 2 ]]; then
  echo "Invalid number of partitions found. Expected 2, provided ${#DEVICES[@]}"
  sudo kpartx -d $FILE
  exit 0
fi

DEVICE="/dev/mapper/${DEVICES[1]}"

TMP_DIR=$(mktemp -d)
sudo mount "$DEVICE" "$TMP_DIR"

if [[ ! -d "$TMP_DIR/etc" ]]; then
  echo "Image does not contain /etc directory"

  sudo umount "$TMP_DIR"
  rm -r "$TMP_DIR"
  sudo kpartx -d $FILE

  exit 0
fi

echo "Opening /etc/rc.local with nano editor"
sudo nano "$TMP_DIR/etc/rc.local"

echo "Cleaning up"
sudo umount "$TMP_DIR"
rm -r "$TMP_DIR"
sudo kpartx -d $FILE
