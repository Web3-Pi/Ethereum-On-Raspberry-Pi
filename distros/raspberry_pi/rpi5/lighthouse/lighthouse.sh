#!/bin/bash
lighthouse bn --network mainnet --execution-endpoint http://localhost:8551 --execution-jwt /home/ethereum/clients/secrets/jwt.hex --checkpoint-sync-url https://mainnet.checkpoint.sigp.io --disable-deposit-contract-sync --http --http-port 5052 --http-address=0.0.0.0 --port 9000
