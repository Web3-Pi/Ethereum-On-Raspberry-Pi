#!/bin/bash

# Read custom config flags from /boot/firmware/config.txt
config_read_file() {
    (grep -E "^${2}=" -m 1 "${1}" 2>/dev/null || echo "VAR=UNDEFINED") | head -n 1 | cut -d '=' -f 2-;
}

config_get() {
    val="$(config_read_file /boot/firmware/config.txt "${1}")";
    printf -- "%s" "${val}";
}


el_url="$(config_get exec-url)";


lighthouse bn --network mainnet --execution-endpoint ${el_url} --execution-jwt /home/ethereum/clients/secrets/jwt.hex --checkpoint-sync-url https://mainnet.checkpoint.sigp.io --disable-deposit-contract-sync --http --http-port 5052 --http-address=0.0.0.0 --port 9000
