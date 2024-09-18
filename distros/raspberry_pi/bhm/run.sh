#!/bin/bash

cd '/opt/web3pi/bhm/'

# Create a virtual environment if it does not exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate the virtual environment
source venv/bin/activate

# Install the required packages
echo "Installing required packages..."
pip install -r requirements.txt

# Run the Python application
echo "Running application"
python3 hwmonitor.py

# Deactivate the virtual environment after finishing
echo "Deactivate the virtual environment"
deactivate

echo 0