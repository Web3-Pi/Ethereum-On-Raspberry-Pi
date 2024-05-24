#!/usr/bin/env bash

set -e
cd /opt/web3pi/basic-eth2-node-monitor
source "venv/bin/activate"
python3 -m pip install -r requirements.txt

# Single node
python3 -u nodemonitor.py -sn "${HOSTNAME}.local" d -db localhost
# or
# Dual node
#python3 nodemonitor.py -dn dual0 ${exec-add} ${exec-ws-port} 7197 ${consensus-add} d ${consensus-port} 7197 -db ${influx-addr} -dbp ${influx-port} -dbc geth geth ethonrpi -wa 7 -wd 10
