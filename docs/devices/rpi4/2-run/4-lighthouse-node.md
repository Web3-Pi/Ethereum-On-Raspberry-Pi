## Running Lighthouse

### Starting a Lighthouse Node

The installation script has already created all the files required to run a node. Setting up and running _lighthouse_ requires a few simple steps.

#### Configure Launch Script

- ssh into _lighthouse-1_ device and go to _lighthouse_ client directory:
  ```bash
  cd ~/clients/lighthouse
  ```
- Open and edit the file _lighthouse.sh_:
  ```bash
  nano lighthouse.sh
  ```
- Remove the first line, uncomment the second line, and provide **the correct execution endpoint address** (e.g., `geth-1.local`)
  - Input:
  ```bash
  echo "Lighthouse command template - specify a valid geth node to connect to, and uncomment the command to use the script"
  #lighthouse bn --network mainnet --execution-endpoint http://YOUR_GETH_NODE_HOSTNAME.local:8551 --execution-jwt /home/ethereum/clients/secrets/jwt.hex --checkpoint-sync-url https://mainnet.checkpoint.sigp.io --disable-deposit-contract-sync
  ```
  - Result for a device hostname set to *geth-1*:
  ```bash
  lighthouse bn --network mainnet --execution-endpoint http://geth-1.local:8551 --execution-jwt /home/ethereum/clients/secrets/jwt.hex --checkpoint-sync-url https://mainnet.checkpoint.sigp..io --disable-deposit-contract-sync
  ```


  > ⚠️⚠️⚠️ **IMPORTANT NOTICE** ⚠️⚠️⚠️
  >
  >  While writing an Image to SD card, you have chosen a hostname for the **Geth Node** (e.g., _geth-1_).
  >
  > The above script must include this name for the **Lighthouse** to run correctly. To connect the **Lighthouse** to the _geth-1_ device:
  > - Change this command line parameter in the above script:
  >
  >   `--execution-endpoint http://`**`YOUR_GETH_NODE_HOSTNAME`**`.local:8551`
  > - To this parameter:
  >
  >   `--execution-endpoint http://`**`geth-1`**`.local:8551`

#### Launch the _lighthouse_ client

Launch the _lighthouse_ client in a screen session by executing these commands:
  ```bash
  cd ~/clients/screen
  ./screen-consensus-cli.sh
  ```


After the above steps and checks, the **lighthouse client** runs in a separate screen session named **lighthouse**.

### Subsequent runs

Launching _lighthouse_ on an already configured device requires following the last step from the previous list, namely

```bash
cd ~/clients/screen
./screen-consensus-cli.sh
```

### Checking status

Because _lighthouse_ is running as an application and not a service, it must be monitored through the associated screen session. Assuming that you are logged into the _lighthouse-1_ device, you can see the _lighthouse_ status using these commands/actions

- `screen -ls` to make sure that the **lighthouse** session is active
- `screen -r lighthouse` to attach to the **lighthouse** session
- To detach from the session, press `Ctrl-a + d`.

## Reference

To ensure the client is synchronized, compare the output with the provided reference logs.

#### Lighthouse in an entry state

⚠️ **TODO** ⚠️

#### Lighthouse - checkpoint syncing:

Synced, but backfilling blocks.

The node is operational, but there are still some historical blocks to download. For additional information, consult the [Lighthouse Book](https://lighthouse-book.sigmaprime.io/checkpoint-sync.html#checkpoint-sync).

![geth synced](./screenshot-lighhouse-backfilling.png)

#### Lighthouse in a synced state:

![geth synced](./screenshot-lighthouse-synced.png)

## Next Step

[➡️ Click here to move to next step & learn about rebooting your nodes. ➡️](./5a-rebooting-device.md)
