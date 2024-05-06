TRUSTED_BLOCK_ROOT=$(curl -s "http://testing.mainnet.beacon-api.nimbus.team/eth/v1/beacon/headers/finalized" | jq -r '.data.root')

nimbus_light_client --web3-url=http://127.0.0.1:8551 --jwt-secret=/home/ethereum/clients/secrets/jwt.hex --trusted-block-root=$TRUSTED_BLOCK_ROOT --data-dir=/home/ethereum/.nimbus/data/shared_mainnet_0 --tcp-port=9000 --udp-port=9000 --rest=true --rest-port=5052 --rest-address=0.0.0.0 --rest-allow-origin='*'
