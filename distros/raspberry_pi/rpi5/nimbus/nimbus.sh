#!/bin/bash
# STAGE 1 - trustedNodeSync
nimbus_beacon_node trustedNodeSync --network:mainnet --data-dir=/home/ethereum/.nimbus/data/shared_mainnet_0 --trusted-node-url=http://18.194.243.122:30307
# STAHE 2 - work mode
nimbus_beacon_node --network:mainnet --data-dir=/home/ethereum/.nimbus/data/shared_mainnet_0 --jwt-secret=/home/ethereum/clients/secrets/jwt.hex --el=http://127.0.0.1:8551 --tcp-port=9000 --udp-port=9000 --rest=true --rest-port=5052 --rest-address=0.0.0.0 --rest-allow-origin='*'
