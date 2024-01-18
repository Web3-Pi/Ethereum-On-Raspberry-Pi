## Overclocking

By default, the Raspberry Pi 4 clock is set to 1.5 GHz, but it is relatively easy to overclock. An overclocked CPU with a significant load will require an active cooling solution or a high-quality cooling case. One example of a chassis with active cooling is [this case](https://botland.com.pl/obudowy-do-raspberry-pi-4b/15106-obudowa-justpi-do-raspberry-pi-4b-aluminiowa-z-dwoma-wentylatorami-czarna-lt-4b02-5903351242660.html).

A detailed analysis of overclocking the Raspberry Pi 4 is available at [this link](https://www.seeedstudio.com/blog/2020/02/12/how-to-safely-overclock-your-raspberry-pi-4-to-2-147ghz/).

**Ethereum On Pi** image has all the instructions already in place but commented out. Overclocking the Raspberry Pi 4 to 2GHz requires the following steps:
- Open the _/boot/firmware/config.txt_ for editing:
  ```bash
  sudo nano /boot/firmware/config.txt
  ```
- Find the last `[all]` section, almost at the end of the file. Look for this comment:
   ```bash
   # The following settings are "defaults" expected to be overridden by the
   # included configuration. The only reason they are included is, again, to
   # support old firmwares which don't understand the "include" command.
   ```
- Right after the comment, there are two lines:
   ```bash
   # over_voltage=6
   # arm_freq=2000
   ```
- Uncomment them, and save the _config.txt_ file by pressing `Ctrl+s`:
   ```bash
   # The following settings are "defaults" expected to be overridden by the
   # included configuration. The only reason they are included is, again, to
   # support old firmwares which don't understand the "include" command.

   over_voltage=6
   arm_freq=2000
   ```
  
- Exit the editor by pressing `Ctrl+x`
- Restart the device:
  ```bash
  sudo reboot
  ```

- After reboot you can check if frequency is correctly recognized by OS
  
   ```bash
  sudo cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
   ```

  It should output `2000000`


If the procedure is successful, the device should be up and running with the updated OC settings.

## Next Step
You are ready to run the **Ethereum Node** on your overclocked devices.

[➡️ Click here to move to next step & learn about prerequisites for running Ethereum Node  ➡️](../2-run/1-prerequisites.md)
