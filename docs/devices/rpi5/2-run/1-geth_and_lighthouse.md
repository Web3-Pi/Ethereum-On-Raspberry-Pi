## Running Geth

### Starting a Geth Node
The installation script has already created all the files required to run a node. Setting up and running _geth_ requires a simple command:

- ssh into Rpi5 device:
  ```bash
  screen geth --authrpc.addr=0.0.0.0 --authrpc.port 8551 --authrpc.vhosts=* --authrpc.jwtsecret /home/raspberry/secrets/jwt.hex --http --http.addr 0.0.0.0 --http.vhosts=* --http.api eth,net,web3 --state.scheme=path
  ```

This will run Geth in new screen sesion.
Pres `Ctrl-a + d` to detach sesion.

## Running Lighthouse

- ssh into Rpi5 device:
  ```bash
  screen lighthouse bn --network mainnet --execution-endpoint http://localhost:8551 --execution-jwt /home/raspberry/secrets/jwt.hex --checkpoint-sync-url https://mainnet.checkpoint.sigp.io --disable-deposit-contract-sync
  ```
This will run Geth in new screen sesion.
Pres `Ctrl-a + d` to detach sesion.


### Checking status
Because _geth_ and _lightlouse_ is running as an application and not a service, it must be monitored through the associated screen session. Assuming that you are logged into the Rpi5 device, you can see the _geth_ and _lightlouse_ status using these commands/actions:
- `screen -ls` to check all sesions ID
- `screen -r ID` to attach to the session
- To detach from the session, press `Ctrl-a + d`.

