#!/usr/bin/env bash

set -e
cd /opt/web3pi/basic-eth2-node-monitor
source "venv/bin/activate"
python3 -m pip install -r requirements.txt

# Read custom config flags from /boot/firmware/config.txt
config_read_file() {
    (grep -E "^${2}=" -m 1 "${1}" 2>/dev/null || echo "VAR=UNDEFINED") | head -n 1 | cut -d '=' -f 2-;
}

config_get() {
    val="$(config_read_file /boot/firmware/config.txt "${1}")";
    printf -- "%s" "${val}";
}

#Execution endpoint address
exec-addr="$(config_get exec-addr)";
exec-port="$(config_get exec-port)";
exec-ws-port="$(config_get exec-ws-port)";

#Consensus endpoint address
consensus-addr="$(config_get consensus-addr)";
consensus-port="$(config_get consensus-port)";

#InfluxDB address
influx-addr="$(config_get influx-addr)";
influx-port="$(config_get influx-port)";


if [ ${exec-add} = "localhost" -a ${consensus-add} = "localhost" ]; then
  #Single node
  #python3 -u nodemonitor.py -sn "${HOSTNAME}.local" d -db ${influx-addr}
  python3 nodemonitor.py -sn "${HOSTNAME}.local" d ${exec-ws-port} ${consensus-port} 7197 -db ${influx-addr} -dbp ${influx-port} -dbc geth geth ethonrpi -wa 7 -wd 10
else
  #Dual node
  python3 nodemonitor.py -dn dual0 ${exec-add} ${exec-ws-port} 7197 ${consensus-add} d ${consensus-port} 7197 -db ${influx-addr} -dbp ${influx-port} -dbc geth geth ethonrpi -wa 7 -wd 10
fi
