## Overclocking

There are two things that can be tweaked at Raspberry po to increase Ethereum Node performance.
- CPU frequency
- PCIe generation

### CPU Overclocking

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

For more information about OC please visit: https://www.jeffgeerling.com/blog/2023/overclocking-and-underclocking-raspberry-pi-5


### PCIe generation select

Raspberry Pi by default use PCIe gen 2. But Broadcom BCM2712 offers PCIe generation 3 which is twice as fast.
By default is set gen. 2 because of compatibility reasons with different adapters.
In most cases, you can safely set gen.3, which improves the performance of NVMe drive twice.

- Edit the _/boot/firmware/config.txt_ for editing:
  ```bash
  sudo nano /boot/firmware/config.txt
  ```
- Find the last `[all]` section, almost at the end of the file. Look for this comment:
   ```bash
   dtparam=pciex1_gen=3
   ```
- Exit the editor by pressing `Ctrl+x` and save changes
- Restart the device:
  ```bash
  sudo reboot
  ```
  
For more information please visit: https://www.jeffgeerling.com/blog/2023/nvme-ssd-boot-raspberry-pi-5


  
## Next Step
You are ready to run the **Ethereum Node** on your overclocked devices.

[➡️ Click here to move to next step & learn about prerequisites for running Ethereum Node  ➡️](../2-run/1-geth-node.md)
