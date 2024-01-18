## Running Geth

### Starting a Geth Node
The installation script has already created all the files required to run a node. Setting up and running _geth_ requires a few simple steps:
- ssh into _geth-1_ device and go to _geth_ client directory:
  ```bash
  cd ~/clients/geth
  ```
- Open and edit the file _geth.sh_:
  ```bash
  nano geth.sh
  ```
- Remove the first line and uncomment the second line:
  - Input
  ```bash
  echo "Geth command template - uncomment the command to use the script"
  #geth --authrpc.addr=0.0.0.0 --authrpc.port 8551 --authrpc.vhosts=* --authrpc.jwtsecret /home/ethereum/clients/secrets/jwt.hex --http --http.addr 0.0.0.0 --http.vhosts=* --http.api eth,net,web3 --state.scheme=path
  ```
  - Result
  ```bash
  geth --authrpc.addr=0.0.0.0 --authrpc.port 8551 --authrpc.vhosts=* --authrpc.jwtsecret /home/ethereum/clients/secrets/jwt.hex --http --http.addr 0.0.0.0 --http.vhosts=* --http.api eth,net,web3 --state.scheme=path
  ```
- Launch the _geth_ client in a screen session by executing these commands:
  ```bash
  cd ~/clients/screen
  ./screen-exec-cli.sh
  ```
  After the above steps, the **go-ethereum client** runs in a separate screen session named **geth**.

### Subsequent runs
Launching _geth_ on an already configured device requires following the last step from the previous list, namely:
```bash
cd ~/clients/screen
./screen-exec-cli.sh
```

### Checking status
Because _geth_ is running as an application and not a service, it must be monitored through the associated screen session. Assuming that you are logged into the _geth-1_ device, you can see the _geth_ status using these commands/actions:
- `screen -ls` to make sure that the **geth** session is active
- `screen -r geth` to attach to the **geth** session
- To detach from the session, press `Ctrl-a + d`.

## Reference
To ensure the client is synchronized, compare the output with the provided reference logs.

#### Geth in a synced state:

![geth synced](./screenshot-geth-synced.png)

## Next Step

[➡️ Click here to move to next step & see how to start lighthouse node. ➡️](./4-lighthouse-node.md)
