## Client Lifecycle
Most of the time, both devices should be turned on and keep processing the Ethereum Blockchain state. On rare occasion, when a device has to be shut down or rebooted, follow the instructions below.

### Rebooting Device
To reboot or shut down a device, log into it and attach to the screen session where the client is running (i.e., `screen -r geth` or `screen -r lighthouse`) and press `Ctrl-c` to stop the client. After the client stops working and exits, the device may be rebooted
```bash
sudo reboot
```
or shut down
```bash
sudo shutdown now
```

### Running Node after Device Reboot
To run a client on a fully configured device (e.g., after a reboot), ssh into the device and execute the last step described in a client configuration section, namely
```bash
cd ~/clients/screen
./screen-exec-cli.sh
```
to execute Geth client in a screen session named **geth**, and similarly
```bash
cd ~/clients/screen
./screen-consensus-cli.sh
```
to execute the Lighthouse client in a screen session named *lighthouse**.

To verify that the session is up and running, type
```bash
screen -ls
```
which will list existing screen sessions.

### Handy screen commands
- `screen -r <session_name>` to attach to an existing session
- `screen -r -d <session_name>` to reattach to an existing, active session
- Press `Ctrl-a + d` to detach from the session

## Next Step

[➡️ Click here to move to next step & learn about monitoring your devices. ➡️](./3b-monitoring.md)
