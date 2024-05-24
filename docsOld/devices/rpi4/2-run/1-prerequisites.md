## Prerequisites

### Hostname Configuration
For the rest of this documentation, it is assumed that there are two **correctly configured** devices named:
- `geth-1` hosting the execution client
- `lighthouse-1` hosting the consensus client

These names are up to the user but must be unique in the chosen subnet to leverage the advantages of mDNS.

_(Those names were set during the process of [creating Raspberry Pi images](../1-setup/3-raspberry-pi-images.md))._

### Networking Considerations
Both devices must be connected to the same LAN subnet (in a home setup, this may correspond to connecting them to the same switch or router). To verify that they are configured correctly, log into both devices with SSH and:
- Login to _geth-1_ and run the command:
  ```bash
  ping lighthouse-1.local
  ```
- Login to _lighthouse-1_ and run the command:
  ```bash
  ping geth-1.local
  ```
  > _If the network configuration is valid, **both devices should be able to reach each other**_
- From both _geth-1_ and _lighthouse-1_ run command:
  ```bash
  ping google.com
  ```
  > _If the network configuration is valid (access to the internet), **both devices should be able to reach the remote host**_

## Next Step

[➡️ Click here to move to next step & see how to setup secure communication between devices. ➡️](./2-secure-communication.md)
