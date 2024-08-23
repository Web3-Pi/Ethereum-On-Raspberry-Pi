#!/bin/bash

# Function to ask for confirmation and wait for a response
ask_confirmation() {
    while true; do
        read -p "Drive will be formated during next run Web3Pi install script. \n Are you sure? (y/n): " yn
        case $yn in
            [Yy]* ) echo "User chose 'yes'."; return 0;;
            [Nn]* ) echo "User chose 'no'."; return 1;;
            * ) echo "Please answer 'y' (yes) or 'n' (no).";;
        esac
    done
}

# Call the function and take appropriate actions based on the response
if ask_confirmation; then
    # user chooses 'yes'
    touch /mnt/storage/.format_me
    echo "success"
else
    # user chooses 'no'
    echo "Cancelling action because the user chose 'no'."
fi