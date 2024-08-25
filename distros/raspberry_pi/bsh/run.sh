#!/usr/bin/env bash

set -e
cd /opt/web3pi/basic-status-http
source "./venv/bin/activate"
python3 -m pip install -r requirements.txt
python3 -u main.py