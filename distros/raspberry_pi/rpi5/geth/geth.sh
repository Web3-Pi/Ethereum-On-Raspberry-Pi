#!/bin/bash
geth --authrpc.port=8551 --http --http.port 8545 --http.addr 0.0.0.0 --http.vhosts '*' --ws --ws.port 8546 --ws.addr 0.0.0.0 --ws.origins '*' --authrpc.jwtsecret /home/ethereum/clients/secrets/jwt.hex --state.scheme=path --discovery.port 30303 --port 30303
