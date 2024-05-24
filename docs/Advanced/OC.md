## Overclocking Raspberry Pi 5

There are two things that can be tweaked at Raspberry Pi 5 to increase Ethereum Node performance.  

  - CPU frequency
  - PCIe generation

!!! note "Note about PCIe generation settings"
    This make sens only if using PCIe to m.2 adapter for storage.

### CPU Overclocking

By default, the Raspberry Pi 5 CPU clock is set to 2.4 GHz, but it is relatively easy to overclock. An overclocked CPU with a significant load will require an active cooling solution or a high-quality cooling case. 

The maximum stable clock that can be achieved depends on a particular device.

Safe for all devices is 2.6 GHz.
The reasonable top is 3.0GHz.

Raspberry Pi has enough power to handle Ethereum node without OC so our recommendation is to keep stable settings like 2.6 GHz


#### How to overclock the CPU
- Edit the _/boot/firmware/config.txt_ for editing:
  ```bash
  sudo nano /boot/firmware/config.txt
  ```
- Find the last `[pi5]` section, almost at the end of the file. Look for this comment:
   ```bash
    [rpi5]
    # Overclocking form Raspberry Pi 5
    # Active cooling is required
    over_voltage_delta=50000
    arm_freq=2800
    #2400MHz is default
    #3000MHz is max (not all boards will work stable)
    #2800MHz is reasonable OC
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

!!! note "For more information about OC Raspberry Pi 5 please visit"
    [https://www.jeffgeerling.com/blog/2023/overclocking-and-underclocking-raspberry-pi-5](https://www.jeffgeerling.com/blog/2023/overclocking-and-underclocking-raspberry-pi-5)


### PCIe generation select

Raspberry Pi by default use PCIe gen 2. But Broadcom BCM2712 offers PCIe generation 3 which is twice as fast.
By default is set gen. 2 because of compatibility reasons with different adapters.
In most cases, you can safely set gen.3, which improves the performance of NVMe drive twice.

- Edit the _/boot/firmware/config.txt_ for editing:
  ```bash
  sudo nano /boot/firmware/config.txt
  ```
- Find the last `[pi5]` section, almost at the end of the file. Look for this comment:
   ```bash
    #Enable PCIe
    dtparam=pciex1
    #Enable PCIe gen.3 (default is gen.2)
    dtparam=pciex1_gen=3
   ```
- Exit the editor by pressing `Ctrl+x` and save changes
- Restart the device:
  ```bash
  sudo reboot
  ```
  
For more information please visit: https://www.jeffgeerling.com/blog/2023/nvme-ssd-boot-raspberry-pi-5




## Overclocking Raspberry Pi 4


To overclock the Raspberry Pi 4, you need to edit the config.txt file located in the /boot/firmware/ directory.

1. **Access the File:**
    - Open a terminal on your Raspberry Pi.
    - Edit the `config.txt` file using a text editor such as `nano`.

    ```sh
    sudo nano /boot/firmware/config.txt
    ```

2. **Add Overclocking Settings:**
    - Uncoment the following lines almost the end of the `config.txt` file. Adjust the values based on your desired overclock settings and the stability of your system.

    ```ini
    [pi4]
    over_voltage=6
    arm_freq=1800
    gpu_freq=600
    ```

    **Explanation:**

    - `over_voltage=6`: Increases the core voltage. Values range from 0 to 8. Higher values increase stability but also generate more heat.
    - `arm_freq=1800`: Sets the CPU frequency to 1800 MHz (1.8 GHz).  
        - The default is 1500 MHz
        - Moderate OC is 1800 MHz
        - High Overclock is 2000 MHz
    - `gpu_freq=600`: Sets the GPU frequency to 600 MHz.
        - The default is 500 MHz
        - Moderate OC is 600 MHz
        - High Overclock is 750 MHz

3. **Save and Reboot:**
    - Save the file (`Ctrl+O` and `Enter` in nano) and exit the text editor (`Ctrl+X` in nano).
    - Reboot the Raspberry Pi to apply the changes.

    ```sh
    sudo reboot
    ```



## Overclocking Raspberry Pi CM4

Overclocking the Raspberry Pi Compute Module 4 (CM4) is similar to overclocking the Raspberry Pi 4, but there are a few key differences to consider due to the form factor and intended use cases of the CM4.

### Similarities

1. **Configuration File:**
    - Both use the `config.txt` file located in the `/boot` directory for overclocking settings.
   
2. **Overclocking Parameters:**
    - Parameters such as `over_voltage`, `arm_freq`, and `gpu_freq` are used in the same way to adjust voltage, CPU frequency, and GPU frequency.

3. **Monitoring and Testing:**
    - Tools and methods for monitoring temperature, checking for throttling, and stress testing are the same.

### Differences

1. **Form Factor and Cooling:**
    - The CM4 is designed to be used with custom carrier boards, which may affect cooling solutions. Ensure your carrier board design allows for adequate cooling, especially when overclocking.

2. **Power Supply:**
    - The power supply and power delivery to the CM4 might be different depending on the carrier board. Ensure that the carrier board can supply sufficient power for overclocking.

## Monitoring and Stability

1. **Monitor Temperatures**
    - Use tools like `vcgencmd` to monitor the temperature of your Raspberry Pi.
    ```sh
    vcgencmd measure_temp
    ```

    - Ideally, temperatures should remain below 85°C. If temperatures are higher, consider improving your cooling solution.

2. **Stress Test**
    - Run stress tests to ensure stability. The `stress` tool can be used for this purpose.

    ```sh
    sudo apt install stress
    stress --cpu 4 --timeout 600
    ```

3. **Check for Throttling**
    - Use `vcgencmd` to check if the Raspberry Pi is throttling due to high temperatures or insufficient power.

    ```sh
    vcgencmd get_throttled
    ```

    - A result of `0x0` indicates no throttling.


## Safety Tips

1. **Incremental Changes:** Start with small increments and gradually increase the values. Monitor stability and temperatures at each step.
2. **Cooling:** Ensure you have sufficient cooling. Consider adding a fan or better heatsinks if necessary.
3. **Power Supply:** Use a high-quality power supply that can handle the increased power demands.
4. **Testing:** Perform extensive testing to ensure that your system remains stable under load.

## Conclusion

Overclocking the Raspberry Pi 4 can provide significant performance improvements, making it more capable for Ethereum node. However, it is crucial to approach overclocking with caution, ensuring adequate cooling and power supply, and thoroughly testing for stability. By following these guidelines, you can safely and effectively overclock your Raspberry Pi to meet your performance needs.