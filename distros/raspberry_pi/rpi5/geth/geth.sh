#!/bin/bash
geth --authrpc.addr=0.0.0.0 --authrpc.port 8551 --authrpc.vhosts=* --authrpc.jwtsecret /home/ethereum/clients/secrets/jwt.hex --http --http.addr 0.0.0.0 --http.vhosts=* --http.api eth,net,web3 --state.scheme=path --ws --ws.port 8546 --ws.addr 0.0.0.0 --ws.origins '*'
