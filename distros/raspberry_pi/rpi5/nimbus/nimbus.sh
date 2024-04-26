#!/bin/bash
nimbus_beacon_node --network:mainnet --data-dir=/home/ethereum/.nimbus/data/shared_mainnet_0 --jwt-secret=/home/ethereum/clients/secrets/jwt.hex --el=http://127.0.0.1:8551 --tcp-port=9000 --udp-port=9000 --rest=true --rest-port=5052 --rest-address=0.0.0.0 --rest-allow-origin='*'
