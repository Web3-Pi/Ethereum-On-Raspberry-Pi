#!/usr/bin/env bash

sed -i 's|DEFAULT_PATH = "/home/"|DEFAULT_PATH = "/mnt/storage/"|' /opt/web3pi/basic-system-monitor/config/conf.py

set -e
cd /opt/web3pi/basic-system-monitor
source "./venv/bin/activate"
python3 -m pip install -r requirements.txt
python3 -u system_monitor.py
