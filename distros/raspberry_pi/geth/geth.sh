#!/bin/bash
geth --authrpc.addr 0.0.0.0 --authrpc.vhosts '*' --authrpc.port 8551 --authrpc.jwtsecret /home/ethereum/clients/secrets/jwt.hex --ws --ws.addr 0.0.0.0 --ws.origins '*' --ws.port 8546 --http --http.addr 0.0.0.0 --http.vhosts '*' --http.port 8545 --state.scheme=path --discovery.port 30303 --port 30303
