#!/usr/bin/env bash

set -e
cd /opt/web3pi/geth-sync-stages-monitoring
source "venv/bin/activate"
python3 -m pip install -r requirements.txt
python3 -u sync_stages_monitor.py
