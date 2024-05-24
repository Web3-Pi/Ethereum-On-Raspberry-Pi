## Secure Communication
Both devices have to establish a secure communication channel. This is achieved by creating a common JWT secret file shared by clients.

The installation script has already generated a common directory structure to store the JWT secret file. To finish the configuration, the secret file has to be generated and populated across devices. Finish the process by executing the following commands:
- ssh into _geth-1_ device and generate a JWT secret file:
  ```bash
  cd
  openssl rand -hex 32 | tr -d "\n" | tee clients/secrets/jwt.hex
  ```
- copy the secret file from _geth-1_ device to the _lighthouse-1_ device:
  ```bash
  cd
  scp clients/secrets/jwt.hex lighthouse-1.local:~/clients/secrets
  ```
  After executing the above actions, the devices can be connected and run as a single **Ethereum Node**.

## Next Step

[➡️ Click here to move to next step & see how to start geth node. ➡️](./3-geth-node.md)
