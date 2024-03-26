## Overclocking


By default, the Raspberry Pi 5 CPU clock is set to 2.4 GHz, but it is relatively easy to overclock. An overclocked CPU with a significant load will require an active cooling solution or a high-quality cooling case. 
The maximum stable clock that can be achieved depends on a particular device.
Safe for all devices is 2.6 GHz.
The reasonable top is 3.0GHz.
Raspberry Pi has enough power to handle Ethereum node without OC so our recommendation is to keep stable settings like 2.6 GHz


### How to overclock CPU
- Edit the _/boot/firmware/config.txt_ for editing:
  ```bash
  sudo nano /boot/firmware/config.txt
  ```
- Find the last `[all]` section, almost at the end of the file. Look for this comment:
   ```bash
   # Tell the DVFS algorithm to increase voltage by this amount (in µV; default 0).
   over_voltage_delta=10000

   # Set the Arm A76 core frequency (in MHz; default 2400).
   arm_freq=2600
   ```
- Exit the editor by pressing `Ctrl+x` and save changes
- Restart the device:
  ```bash
  sudo reboot
  ```
- After reboot you can check if frequency is correctly recognized by OS
  
   ```bash
  sudo cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
   ```

  It should output `2600000`


If the procedure is successful, the device should be up and running with the updated OC settings.

## Next Step
You are ready to run the **Ethereum Node** on your overclocked devices.

[➡️ Click here to move to next step & learn about prerequisites for running Ethereum Node  ➡️](../2-run/1-geth-node.md)
