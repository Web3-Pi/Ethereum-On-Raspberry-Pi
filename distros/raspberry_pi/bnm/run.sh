#!/usr/bin/env bash

set -e
cd /opt/web3pi/basic-eth2-node-monitor
source "venv/bin/activate"
python3 -m pip install -r requirements.txt

#echo "Delay of 2 minutes before start"
#sleep 2m

# Single node
python3 -u nodemonitor.py -sn "${HOSTNAME}.local" d -db localhost
# or
# Dual node (run on eop-consensus.local)
#python3 nodemonitor.py -dn dual0 eop-exec.local eop-consensus.local d -db localhost
